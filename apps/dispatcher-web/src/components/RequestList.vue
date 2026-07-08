<script setup lang="ts">
import type { RelocationRequest } from '../types/relocation'
import StatusBadge from './StatusBadge.vue'

defineProps<{
  requests: RelocationRequest[]
  loading: boolean
  error: string | null
}>()

const emit = defineEmits<{ edit: [request: RelocationRequest]; retry: [] }>()

function formatDate(value: string) {
  return new Date(value + 'T00:00:00').toLocaleDateString(undefined, {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
}
</script>

<template>
  <div>
    <div v-if="loading" class="space-y-3">
      <div v-for="i in 3" :key="i" class="h-20 animate-pulse rounded-xl bg-gray-100 dark:bg-gray-800" />
    </div>

    <div
      v-else-if="error"
      class="rounded-xl border border-red-200 bg-red-50 p-6 text-center dark:border-red-900 dark:bg-red-950"
    >
      <p class="text-sm text-red-700 dark:text-red-300">{{ error }}</p>
      <button
        type="button"
        @click="emit('retry')"
        class="mt-3 rounded-lg bg-red-600 px-4 py-1.5 text-sm font-medium text-white hover:bg-red-500"
      >
        Retry
      </button>
    </div>

    <div
      v-else-if="requests.length === 0"
      class="rounded-xl border border-dashed border-gray-300 p-10 text-center dark:border-gray-700"
    >
      <p class="text-sm text-gray-500 dark:text-gray-400">No relocation requests yet.</p>
      <p class="mt-1 text-xs text-gray-400 dark:text-gray-500">Create your first one to get started.</p>
    </div>

    <ul v-else class="space-y-3">
      <li
        v-for="request in requests"
        :key="request.id"
        class="cursor-pointer rounded-xl border border-gray-200 bg-white p-4 shadow-sm transition hover:border-indigo-300 hover:shadow-md dark:border-gray-800 dark:bg-gray-900"
        @click="emit('edit', request)"
      >
        <div class="flex items-start justify-between gap-3">
          <div class="min-w-0">
            <p class="truncate font-medium text-gray-900 dark:text-white">
              {{ request.origin }} → {{ request.destination }}
            </p>
            <p class="mt-0.5 text-sm text-gray-500 dark:text-gray-400">{{ formatDate(request.scheduled_date) }}</p>
            <p v-if="request.notes" class="mt-1 truncate text-sm text-gray-400 dark:text-gray-500">
              {{ request.notes }}
            </p>
          </div>
          <StatusBadge :status="request.status" class="shrink-0" />
        </div>
      </li>
    </ul>
  </div>
</template>
