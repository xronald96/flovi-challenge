import { chromium } from '@playwright/test'
import { createClient } from '@supabase/supabase-js'
import fs from 'node:fs'

// Provisions a real, authenticated session for a dedicated e2e test user against the test
// Supabase project, and saves it as Playwright storage state so every test starts already
// signed in — without a human ever clicking through Google's consent screen (which can't be
// automated). The session is genuine: minted via a real password sign-in, not fabricated.
export default async function globalSetup() {
  const required = {
    TEST_SUPABASE_URL: process.env.TEST_SUPABASE_URL,
    TEST_SUPABASE_ANON_KEY: process.env.TEST_SUPABASE_ANON_KEY,
    TEST_SUPABASE_SERVICE_ROLE_KEY: process.env.TEST_SUPABASE_SERVICE_ROLE_KEY,
    TEST_USER_EMAIL: process.env.TEST_USER_EMAIL,
    TEST_USER_PASSWORD: process.env.TEST_USER_PASSWORD,
  }
  for (const [name, value] of Object.entries(required)) {
    if (!value) {
      throw new Error(`Missing ${name} — copy .env.test.example to .env.test and fill it in.`)
    }
  }
  const { TEST_SUPABASE_URL, TEST_SUPABASE_ANON_KEY, TEST_SUPABASE_SERVICE_ROLE_KEY, TEST_USER_EMAIL, TEST_USER_PASSWORD } =
    required as Record<string, string>

  const admin = createClient(TEST_SUPABASE_URL, TEST_SUPABASE_SERVICE_ROLE_KEY)

  const { error: createError } = await admin.auth.admin.createUser({
    email: TEST_USER_EMAIL,
    password: TEST_USER_PASSWORD,
    email_confirm: true,
  })
  if (createError && !createError.message.includes('already been registered')) {
    throw createError
  }

  const anon = createClient(TEST_SUPABASE_URL, TEST_SUPABASE_ANON_KEY)
  const { data, error: signInError } = await anon.auth.signInWithPassword({
    email: TEST_USER_EMAIL,
    password: TEST_USER_PASSWORD,
  })
  if (signInError || !data.session) {
    throw signInError ?? new Error('No session returned from sign-in.')
  }

  const projectRef = new URL(TEST_SUPABASE_URL).hostname.split('.')[0]
  const storageKey = `sb-${projectRef}-auth-token`

  const browser = await chromium.launch()
  const context = await browser.newContext({ baseURL: 'http://localhost:5173' })
  const page = await context.newPage()
  await page.goto('http://localhost:5173')
  await page.evaluate(
    ([key, value]) => window.localStorage.setItem(key, value),
    [storageKey, JSON.stringify(data.session)],
  )

  fs.mkdirSync('./e2e/.auth', { recursive: true })
  await context.storageState({ path: './e2e/.auth/state.json' })
  await browser.close()
}
