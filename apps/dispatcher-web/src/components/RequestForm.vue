<script setup lang="ts">
import { ref } from 'vue'
import type { RelocationRequest, RelocationRequestInput, RelocationStatus } from '../types/relocation'

const props = defineProps<{
  request?: RelocationRequest | null
  submitting: boolean
}>()

const emit = defineEmits<{
  submit: [input: RelocationRequestInput & { status?: RelocationStatus }]
  cancel: []
}>()

const origin = ref(props.request?.origin ?? '')
const destination = ref(props.request?.destination ?? '')
const scheduledDate = ref(props.request?.scheduled_date ?? '')
const notes = ref(props.request?.notes ?? '')
const status = ref<RelocationStatus>(props.request?.status ?? 'pending')

const today = new Date().toISOString().slice(0, 10)

const errors = ref<Record<string, string>>({})

function validate(): boolean {
  const next: Record<string, string> = {}
  if (!origin.value.trim()) next.origin = 'Origin is required.'
  if (!destination.value.trim()) next.destination = 'Destination is required.'
  if (!scheduledDate.value) next.scheduledDate = 'Date is required.'
  else if (scheduledDate.value < today) next.scheduledDate = 'Date cannot be in the past.'
  errors.value = next
  return Object.keys(next).length === 0
}

function handleSubmit() {
  if (!validate()) return
  emit('submit', {
    origin: origin.value.trim(),
    destination: destination.value.trim(),
    scheduled_date: scheduledDate.value,
    notes: notes.value.trim() || null,
    ...(props.request ? { status: status.value } : {}),
  })
}
</script>

<template>
  <form class="space-y-4" @submit.prevent="handleSubmit">
    <div>
      <label class="mb-1 block text-sm font-medium text-gray-700 dark:text-gray-300">Origin</label>
      <input
        v-model="origin"
        type="text"
        placeholder="e.g. Chicago, IL"
        class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 dark:border-gray-700 dark:bg-gray-800 dark:text-white"
      />
      <p v-if="errors.origin" class="mt-1 text-xs text-red-600 dark:text-red-400">{{ errors.origin }}</p>
    </div>

    <div>
      <label class="mb-1 block text-sm font-medium text-gray-700 dark:text-gray-300">Destination</label>
      <input
        v-model="destination"
        type="text"
        placeholder="e.g. Austin, TX"
        class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 dark:border-gray-700 dark:bg-gray-800 dark:text-white"
      />
      <p v-if="errors.destination" class="mt-1 text-xs text-red-600 dark:text-red-400">{{ errors.destination }}</p>
    </div>

    <div>
      <label class="mb-1 block text-sm font-medium text-gray-700 dark:text-gray-300">Date</label>
      <input
        v-model="scheduledDate"
        type="date"
        :min="today"
        class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 dark:border-gray-700 dark:bg-gray-800 dark:text-white"
      />
      <p v-if="errors.scheduledDate" class="mt-1 text-xs text-red-600 dark:text-red-400">{{ errors.scheduledDate }}</p>
    </div>

    <div>
      <label class="mb-1 block text-sm font-medium text-gray-700 dark:text-gray-300">Notes</label>
      <textarea
        v-model="notes"
        rows="3"
        placeholder="Optional details for the driver"
        class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 dark:border-gray-700 dark:bg-gray-800 dark:text-white"
      />
    </div>

    <div v-if="props.request">
      <label class="mb-1 block text-sm font-medium text-gray-700 dark:text-gray-300">Status</label>
      <select
        v-model="status"
        class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 dark:border-gray-700 dark:bg-gray-800 dark:text-white"
      >
        <option value="pending">Pending</option>
        <option value="booked">Booked</option>
        <option value="completed">Completed</option>
        <option value="cancelled">Cancelled</option>
      </select>
    </div>

    <div class="flex justify-end gap-2 pt-2">
      <button
        type="button"
        @click="emit('cancel')"
        class="rounded-lg px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800"
      >
        Cancel
      </button>
      <button
        type="submit"
        :disabled="submitting"
        class="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm transition hover:bg-indigo-500 disabled:cursor-not-allowed disabled:opacity-60"
      >
        {{ submitting ? 'Saving…' : props.request ? 'Save changes' : 'Create request' }}
      </button>
    </div>
  </form>
</template>
