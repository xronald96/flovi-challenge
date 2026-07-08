import { createClient } from '@supabase/supabase-js'

// beforeEach wipes the table before every test, but that leaves the last test's rows in
// place until the next run. Clean up after the whole suite too, so the test project never
// sits with stray data between runs.
export default async function globalTeardown() {
  const admin = createClient(process.env.TEST_SUPABASE_URL!, process.env.TEST_SUPABASE_SERVICE_ROLE_KEY!)
  await admin.from('relocation_requests').delete().not('id', 'is', null)
}
