import { ref } from 'vue'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'

// Module-level (singleton) state so every component sees the same auth session
// without pulling in a state-management library for one value.
const session = ref<Session | null>(null)
const authReady = ref(false)

supabase.auth.getSession().then(({ data }) => {
  session.value = data.session
  authReady.value = true
})

supabase.auth.onAuthStateChange((_event, newSession) => {
  session.value = newSession
})

async function signInWithGoogle() {
  const { error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: { redirectTo: window.location.origin },
  })
  if (error) throw error
}

async function signOut() {
  const { error } = await supabase.auth.signOut()
  if (error) throw error
}

export function useAuth() {
  return { session, authReady, signInWithGoogle, signOut }
}
