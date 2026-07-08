import { ref } from 'vue'
import type { RealtimeChannel } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'
import type { RelocationRequest, RelocationRequestInput, RelocationStatus } from '../types/relocation'

const requests = ref<RelocationRequest[]>([])
const loading = ref(false)
const error = ref<string | null>(null)
let channel: RealtimeChannel | null = null

async function fetchAll() {
  loading.value = true
  error.value = null
  const { data, error: fetchError } = await supabase
    .from('relocation_requests')
    .select('*')
    .order('created_at', { ascending: false })

  if (fetchError) {
    error.value = fetchError.message
  } else {
    requests.value = data as RelocationRequest[]
  }
  loading.value = false
}

async function createRequest(input: RelocationRequestInput) {
  const { data: userData } = await supabase.auth.getUser()
  const userId = userData.user?.id
  if (!userId) throw new Error('You must be signed in to create a request.')

  const { error: insertError } = await supabase.from('relocation_requests').insert({
    ...input,
    created_by: userId,
  })
  if (insertError) throw insertError
}

async function updateRequest(
  id: string,
  patch: Partial<RelocationRequestInput> & { status?: RelocationStatus },
) {
  const { error: updateError } = await supabase.from('relocation_requests').update(patch).eq('id', id)
  if (updateError) throw updateError
}

function upsertLocal(row: RelocationRequest) {
  const index = requests.value.findIndex((r) => r.id === row.id)
  if (index === -1) {
    requests.value = [row, ...requests.value]
  } else {
    requests.value = requests.value.map((r) => (r.id === row.id ? row : r))
  }
}

function removeLocal(id: string) {
  requests.value = requests.value.filter((r) => r.id !== id)
}

function subscribeRealtime() {
  if (channel) return
  channel = supabase
    .channel('relocation_requests-dispatcher')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'relocation_requests' },
      (payload) => {
        if (payload.eventType === 'DELETE') {
          removeLocal((payload.old as RelocationRequest).id)
        } else {
          upsertLocal(payload.new as RelocationRequest)
        }
      },
    )
    .subscribe((status, err) => {
      if (status !== 'SUBSCRIBED') {
        console.error('[realtime] relocation_requests channel problem:', status, err ?? '')
      }
    })
}

function unsubscribeRealtime() {
  if (channel) {
    supabase.removeChannel(channel)
    channel = null
  }
}

export function useRelocationRequests() {
  return {
    requests,
    loading,
    error,
    fetchAll,
    createRequest,
    updateRequest,
    subscribeRealtime,
    unsubscribeRealtime,
  }
}
