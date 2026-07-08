// Mirrors packages/shared/model.md — keep in sync with supabase/schema.sql.

export type RelocationStatus = 'pending' | 'booked' | 'completed' | 'cancelled'

export interface RelocationRequest {
  id: string
  origin: string
  destination: string
  scheduled_date: string
  notes: string | null
  status: RelocationStatus
  created_by: string
  booked_by: string | null
  created_at: string
  updated_at: string
}

export interface RelocationRequestInput {
  origin: string
  destination: string
  scheduled_date: string
  notes: string | null
}

export const STATUS_LABEL: Record<RelocationStatus, string> = {
  pending: 'Pending',
  booked: 'Booked',
  completed: 'Completed',
  cancelled: 'Cancelled',
}

export const STATUS_BADGE_CLASS: Record<RelocationStatus, string> = {
  pending: 'bg-amber-100 text-amber-800 dark:bg-amber-400/10 dark:text-amber-300',
  booked: 'bg-blue-100 text-blue-800 dark:bg-blue-400/10 dark:text-blue-300',
  completed: 'bg-emerald-100 text-emerald-800 dark:bg-emerald-400/10 dark:text-emerald-300',
  cancelled: 'bg-gray-100 text-gray-600 dark:bg-gray-400/10 dark:text-gray-400',
}
