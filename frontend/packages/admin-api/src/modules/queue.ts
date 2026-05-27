import client from '../client'
import type { AdminQueue, AdminPaginatedResult } from '@diandantong/admin-types'

export const queueApi = {
  list(params?: { branch_id?: number; status?: string; page?: number; per_page?: number }) {
    return client.get<AdminPaginatedResult<AdminQueue>>('/queues', { params })
  },

  callNext(queueId: number) {
    return client.post<AdminQueue>(`/queues/${queueId}/call`)
  },

  cancel(queueId: number) {
    return client.post<AdminQueue>(`/queues/${queueId}/cancel`)
  },

  seat(queueId: number, tableId?: number) {
    return client.post<AdminQueue>(`/queues/${queueId}/seat`, { table_id: tableId })
  },
}
