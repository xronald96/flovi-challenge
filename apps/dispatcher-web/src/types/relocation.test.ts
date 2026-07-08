import { describe, expect, it } from 'vitest'
import { STATUS_BADGE_CLASS, STATUS_LABEL, type RelocationStatus } from './relocation'

const ALL_STATUSES: RelocationStatus[] = ['pending', 'booked', 'completed', 'cancelled']

describe('relocation status maps', () => {
  it('has a non-empty label for every status', () => {
    for (const status of ALL_STATUSES) {
      expect(STATUS_LABEL[status]).toBeTruthy()
    }
  })

  it('has a non-empty badge class for every status', () => {
    for (const status of ALL_STATUSES) {
      expect(STATUS_BADGE_CLASS[status]).toBeTruthy()
    }
  })

  it('gives every status a distinct label', () => {
    const labels = ALL_STATUSES.map((status) => STATUS_LABEL[status])
    expect(new Set(labels).size).toBe(ALL_STATUSES.length)
  })
})
