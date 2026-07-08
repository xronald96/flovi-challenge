import { test, expect } from '@playwright/test'
import { createClient } from '@supabase/supabase-js'

// Real e2e against the dedicated test Supabase project — no mocked network, no fake data
// layer. See global-setup.ts for how auth is bootstrapped without a human OAuth click.
const admin = createClient(process.env.TEST_SUPABASE_URL!, process.env.TEST_SUPABASE_SERVICE_ROLE_KEY!)

let testUserId: string

test.beforeAll(async () => {
  const { data, error } = await admin.auth.admin.listUsers()
  if (error) throw error
  const user = data.users.find((u) => u.email === process.env.TEST_USER_EMAIL)
  if (!user) throw new Error('Test user not found — did global-setup run?')
  testUserId = user.id
})

test.beforeEach(async () => {
  // Shared dataset in a dedicated test project: wipe it clean before every test rather than
  // tracking per-test IDs to delete individually.
  await admin.from('relocation_requests').delete().not('id', 'is', null)
})

test('shows the empty state with no requests', async ({ page }) => {
  await page.goto('/')
  await expect(page.getByText('No relocation requests yet.')).toBeVisible()
})

test('creates a request and shows it with a Pending badge', async ({ page }) => {
  await page.goto('/')
  await page.getByRole('button', { name: '+ New request' }).click()
  await page.getByPlaceholder('e.g. Chicago, IL').fill('Seattle, WA')
  await page.getByPlaceholder('e.g. Austin, TX').fill('Portland, OR')
  await page.locator('input[type="date"]').fill('2099-06-15')
  await page.getByRole('button', { name: 'Create request' }).click()

  await expect(page.getByText('Seattle, WA → Portland, OR')).toBeVisible()
  await expect(page.getByText('Pending')).toBeVisible()
})

test('edits a request and its status change persists', async ({ page }) => {
  await admin.from('relocation_requests').insert({
    origin: 'Denver, CO',
    destination: 'Phoenix, AZ',
    scheduled_date: '2099-06-15',
    status: 'pending',
    created_by: testUserId,
  })

  await page.goto('/')
  await page.getByText('Denver, CO → Phoenix, AZ').click()
  await page.locator('select').selectOption('booked')
  await page.getByRole('button', { name: 'Save changes' }).click()

  await expect(page.getByText('Booked')).toBeVisible()
  await page.reload()
  await expect(page.getByText('Booked')).toBeVisible()
})

test('rejects a past date without creating a request', async ({ page }) => {
  await page.goto('/')
  await page.getByRole('button', { name: '+ New request' }).click()
  await page.getByPlaceholder('e.g. Chicago, IL').fill('Nowhere, XX')
  await page.getByPlaceholder('e.g. Austin, TX').fill('Nowhere Else, XX')
  await page.locator('input[type="date"]').fill('2000-01-01')
  await page.getByRole('button', { name: 'Create request' }).click()

  await expect(page.getByText('Date cannot be in the past.')).toBeVisible()
  await expect(page.getByText('Nowhere, XX → Nowhere Else, XX')).not.toBeVisible()
})

test('realtime: a change in one tab is reflected live in another', async ({ browser }) => {
  const context1 = await browser.newContext({ storageState: './e2e/.auth/state.json' })
  const context2 = await browser.newContext({ storageState: './e2e/.auth/state.json' })
  const page1 = await context1.newPage()
  const page2 = await context2.newPage()

  try {
    await page1.goto('/')
    await page2.goto('/')

    await page1.getByRole('button', { name: '+ New request' }).click()
    await page1.getByPlaceholder('e.g. Chicago, IL').fill('Miami, FL')
    await page1.getByPlaceholder('e.g. Austin, TX').fill('Orlando, FL')
    await page1.locator('input[type="date"]').fill('2099-06-15')
    await page1.getByRole('button', { name: 'Create request' }).click()

    await expect(page2.getByText('Miami, FL → Orlando, FL')).toBeVisible({ timeout: 10_000 })
  } finally {
    await context1.close()
    await context2.close()
  }
})
