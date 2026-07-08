<script setup lang="ts">
import { ref, watch } from 'vue'
import { useAuth } from './composables/useAuth'
import { useRelocationRequests } from './composables/useRelocationRequests'
import type { RelocationRequest } from './types/relocation'
import LoginView from './components/LoginView.vue'
import RequestList from './components/RequestList.vue'
import RequestForm from './components/RequestForm.vue'
import Modal from './components/Modal.vue'

const { session, authReady, signOut } = useAuth()
const { requests, loading, error, fetchAll, createRequest, updateRequest, subscribeRealtime, unsubscribeRealtime } =
  useRelocationRequests()

const showForm = ref(false)
const editingRequest = ref<RelocationRequest | null>(null)
const submitting = ref(false)
const toast = ref<{ kind: 'success' | 'error'; message: string } | null>(null)

function showToast(kind: 'success' | 'error', message: string) {
  toast.value = { kind, message }
  setTimeout(() => {
    toast.value = null
  }, 3000)
}

watch(
  session,
  (value) => {
    if (value) {
      fetchAll()
      subscribeRealtime()
    } else {
      unsubscribeRealtime()
    }
  },
  { immediate: true },
)

function openCreate() {
  editingRequest.value = null
  showForm.value = true
}

function openEdit(request: RelocationRequest) {
  editingRequest.value = request
  showForm.value = true
}

function closeForm() {
  showForm.value = false
  editingRequest.value = null
}

async function handleSubmit(input: Parameters<typeof createRequest>[0] & { status?: string }) {
  submitting.value = true
  try {
    if (editingRequest.value) {
      await updateRequest(editingRequest.value.id, input as never)
      showToast('success', 'Request updated.')
    } else {
      await createRequest(input)
      showToast('success', 'Request created.')
    }
    closeForm()
  } catch (e) {
    showToast('error', e instanceof Error ? e.message : 'Something went wrong. Please try again.')
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div v-if="!authReady" class="flex min-h-svh items-center justify-center text-gray-400">Loading…</div>

  <LoginView v-else-if="!session" />

  <div v-else class="min-h-svh bg-gray-50 dark:bg-gray-950">
    <header class="border-b border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
      <div class="mx-auto flex max-w-2xl items-center justify-between px-4 py-4">
        <div class="flex items-center gap-2">
          <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-indigo-600 text-sm font-bold text-white">
            F
          </div>
          <span class="font-semibold text-gray-900 dark:text-white">Flovi Dispatcher</span>
        </div>
        <button
          type="button"
          @click="signOut()"
          class="text-sm text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
        >
          Sign out
        </button>
      </div>
    </header>

    <main class="mx-auto max-w-2xl px-4 py-8">
      <div class="mb-6 flex items-center justify-between">
        <h1 class="text-xl font-semibold text-gray-900 dark:text-white">Relocation requests</h1>
        <button
          type="button"
          @click="openCreate"
          class="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-500"
        >
          + New request
        </button>
      </div>

      <RequestList :requests="requests" :loading="loading" :error="error" @edit="openEdit" @retry="fetchAll" />
    </main>

    <Modal v-if="showForm" :title="editingRequest ? 'Edit request' : 'New request'" @close="closeForm">
      <RequestForm :request="editingRequest" :submitting="submitting" @submit="handleSubmit" @cancel="closeForm" />
    </Modal>

    <div
      v-if="toast"
      class="fixed bottom-4 left-1/2 -translate-x-1/2 rounded-lg px-4 py-2 text-sm font-medium text-white shadow-lg"
      :class="toast.kind === 'success' ? 'bg-emerald-600' : 'bg-red-600'"
    >
      {{ toast.message }}
    </div>
  </div>
</template>
