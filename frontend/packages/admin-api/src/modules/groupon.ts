import client from '../client'
import type { AdminGroupon, AdminPaginatedResult } from '@diandantong/admin-types'

export const grouponApi = {
  list(params?: { page?: number; per_page?: number; status?: string }) {
    return client.get<AdminPaginatedResult<AdminGroupon>>('/groups', { params })
  },

  create(data: Partial<AdminGroupon>) {
    return client.post<AdminGroupon>('/groups', data)
  },

  update(grouponId: number, data: Partial<AdminGroupon>) {
    return client.put<AdminGroupon>(`/groups/${grouponId}`, data)
  },

  delete(grouponId: number) {
    return client.delete(`/groups/${grouponId}`)
  },
}
