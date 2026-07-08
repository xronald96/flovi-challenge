import { defineConfig, devices } from '@playwright/test'

// Runs against a dedicated test Supabase project (see .env.test.example), not the live demo
// project. Serial, single-worker: tests share one small dataset and wipe it between runs
// rather than each managing isolated fixtures — see e2e/dispatcher.spec.ts.
export default defineConfig({
  testDir: './e2e',
  fullyParallel: false,
  workers: 1,
  retries: 0,
  reporter: 'list',
  globalSetup: './e2e/global-setup.ts',
  globalTeardown: './e2e/global-teardown.ts',
  use: {
    baseURL: 'http://localhost:5173',
    storageState: './e2e/.auth/state.json',
    trace: 'retain-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
    env: {
      VITE_SUPABASE_URL: process.env.TEST_SUPABASE_URL ?? '',
      VITE_SUPABASE_ANON_KEY: process.env.TEST_SUPABASE_ANON_KEY ?? '',
    },
  },
})
