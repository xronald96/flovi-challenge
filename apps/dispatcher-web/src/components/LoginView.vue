<script setup lang="ts">
import { ref } from 'vue'
import { useAuth } from '../composables/useAuth'

const { signInWithGoogle } = useAuth()
const error = ref<string | null>(null)
const submitting = ref(false)

async function handleSignIn() {
  error.value = null
  submitting.value = true
  try {
    await signInWithGoogle()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Sign-in failed. Please try again.'
    submitting.value = false
  }
}
</script>

<template>
  <div class="flex min-h-svh items-center justify-center bg-gray-50 px-4 dark:bg-gray-950">
    <div class="w-full max-w-sm rounded-2xl border border-gray-200 bg-white p-8 shadow-sm dark:border-gray-800 dark:bg-gray-900">
      <div class="mb-6 text-center">
        <div class="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-indigo-600 text-xl font-bold text-white">
          F
        </div>
        <h1 class="text-xl font-semibold text-gray-900 dark:text-white">Flovi Dispatcher</h1>
        <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
          Sign in to create and manage relocation requests.
        </p>
      </div>

      <button
        type="button"
        :disabled="submitting"
        @click="handleSignIn"
        class="flex w-full items-center justify-center gap-3 rounded-lg border border-gray-300 bg-white px-4 py-2.5 text-sm font-medium text-gray-700 shadow-sm transition hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-60 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 dark:hover:bg-gray-700"
      >
        <svg class="h-5 w-5" viewBox="0 0 24 24">
          <path fill="#4285F4" d="M23.52 12.27c0-.85-.08-1.67-.22-2.45H12v4.64h6.47c-.28 1.5-1.13 2.78-2.4 3.63v3.02h3.88c2.27-2.09 3.57-5.17 3.57-8.84z" />
          <path fill="#34A853" d="M12 24c3.24 0 5.96-1.07 7.95-2.9l-3.88-3.02c-1.08.72-2.45 1.15-4.07 1.15-3.13 0-5.78-2.11-6.73-4.95H1.27v3.11C3.25 21.3 7.28 24 12 24z" />
          <path fill="#FBBC05" d="M5.27 14.28A7.2 7.2 0 0 1 4.87 12c0-.79.14-1.56.4-2.28V6.61H1.27A11.98 11.98 0 0 0 0 12c0 1.93.46 3.76 1.27 5.39z" />
          <path fill="#EA4335" d="M12 4.77c1.76 0 3.35.61 4.6 1.8l3.44-3.44C17.95 1.19 15.24 0 12 0 7.28 0 3.25 2.7 1.27 6.61l3.99 3.11C6.22 6.88 8.87 4.77 12 4.77z" />
        </svg>
        {{ submitting ? 'Redirecting…' : 'Sign in with Google' }}
      </button>

      <p v-if="error" class="mt-4 text-center text-sm text-red-600 dark:text-red-400">{{ error }}</p>
    </div>
  </div>
</template>
