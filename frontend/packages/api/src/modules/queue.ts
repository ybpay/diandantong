import client from '../client'
import type { GuestQueue, PaginatedResult } from '@webpos/types'

export const queueApi = {
  list(branchId: number, params?: { status?: string }) {
    return client.get<PaginatedResult<GuestQueue>>(`/branches/${branchId}/guest_queues`, { params })
  },

  create(branchId: number, data: { name: string; phone?: string; guest_num: number }) {
    return client.post<GuestQueue>(`/branches/${branchId}/guest_queues`, data)
  },

  call(branchId: number, queueId: number) {
    return client.post<GuestQueue>(`/branches/${branchId}/guest_queues/${queueId}/call`)
  },

  seat(branchId: number, queueId: number, tableId?: number) {
    return client.post<GuestQueue>(`/branches/${branchId}/guest_queues/${queueId}/seat`, { table_id: tableId })
  },

  cancel(branchId: number, queueId: number) {
    return client.post<GuestQueue>(`/branches/${branchId}/guest_queues/${queueId}/cancel`)
  },
}
