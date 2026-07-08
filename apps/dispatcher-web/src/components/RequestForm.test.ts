import { describe, expect, it } from 'vitest'
import { mount } from '@vue/test-utils'
import RequestForm from './RequestForm.vue'
import type { RelocationRequest, RelocationRequestInput, RelocationStatus } from '../types/relocation'

type SubmitPayload = RelocationRequestInput & { status?: RelocationStatus }

const baseRequest: RelocationRequest = {
  id: 'req-1',
  origin: 'Chicago, IL',
  destination: 'Austin, TX',
  scheduled_date: '2099-01-01',
  notes: 'Handle with care',
  status: 'pending',
  created_by: 'user-1',
  booked_by: null,
  created_at: '2026-01-01T00:00:00Z',
  updated_at: '2026-01-01T00:00:00Z',
}

describe('RequestForm', () => {
  it('shows required-field errors and does not emit submit when empty', async () => {
    const wrapper = mount(RequestForm, { props: { submitting: false } })

    await wrapper.find('form').trigger('submit.prevent')

    expect(wrapper.text()).toContain('Origin is required.')
    expect(wrapper.text()).toContain('Destination is required.')
    expect(wrapper.text()).toContain('Date is required.')
    expect(wrapper.emitted('submit')).toBeUndefined()
  })

  it('rejects a past date', async () => {
    const wrapper = mount(RequestForm, { props: { submitting: false } })

    await wrapper.find('input[placeholder="e.g. Chicago, IL"]').setValue('Chicago, IL')
    await wrapper.find('input[placeholder="e.g. Austin, TX"]').setValue('Austin, TX')
    await wrapper.find('input[type="date"]').setValue('2000-01-01')
    await wrapper.find('form').trigger('submit.prevent')

    expect(wrapper.text()).toContain('Date cannot be in the past.')
    expect(wrapper.emitted('submit')).toBeUndefined()
  })

  it('emits a create payload without a status field when there is no existing request', async () => {
    const wrapper = mount(RequestForm, { props: { submitting: false } })

    await wrapper.find('input[placeholder="e.g. Chicago, IL"]').setValue('Chicago, IL')
    await wrapper.find('input[placeholder="e.g. Austin, TX"]').setValue('Austin, TX')
    await wrapper.find('input[type="date"]').setValue('2099-01-01')
    await wrapper.find('textarea').setValue('Fragile')
    await wrapper.find('form').trigger('submit.prevent')

    const submitted = wrapper.emitted('submit')
    expect(submitted).toHaveLength(1)
    const payload = submitted![0][0] as SubmitPayload
    expect(payload).toEqual({
      origin: 'Chicago, IL',
      destination: 'Austin, TX',
      scheduled_date: '2099-01-01',
      notes: 'Fragile',
    })
    expect(Object.hasOwn(payload, 'status')).toBe(false)
  })

  it('includes the status field when editing an existing request', async () => {
    const wrapper = mount(RequestForm, { props: { request: baseRequest, submitting: false } })

    await wrapper.find('select').setValue('booked')
    await wrapper.find('form').trigger('submit.prevent')

    const submitted = wrapper.emitted('submit')
    expect(submitted).toHaveLength(1)
    expect((submitted![0][0] as SubmitPayload).status).toBe('booked')
  })

  it('emits cancel when the cancel button is clicked', async () => {
    const wrapper = mount(RequestForm, { props: { submitting: false } })

    await wrapper.find('button[type="button"]').trigger('click')

    expect(wrapper.emitted('cancel')).toHaveLength(1)
  })
})
