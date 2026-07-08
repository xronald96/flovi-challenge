<script setup lang="ts">
import { STATUS_BADGE_CLASS, STATUS_LABEL, type RelocationStatus } from '../types/relocation'

defineProps<{ status: RelocationStatus }>()
</script>

<template>
  <span
    class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium"
    :class="STATUS_BADGE_CLASS[status]"
  >
    {{ STATUS_LABEL[status] }}
  </span>
</template>
