import client from '../client'
import type { AdminRole, AdminPaginatedResult } from '@diandantong/admin-types'

export const roleApi = {
  list(params?: { page?: number; per_page?: number }) {
    return client.get<AdminPaginatedResult<AdminRole>>('/roles', { params })
  },

  create(data: Partial<AdminRole>) {
    return client.post<AdminRole>('/roles', data)
  },

  update(roleId: number, data: Partial<AdminRole>) {
    return client.put<AdminRole>(`/roles/${roleId}`, data)
  },

  delete(roleId: number) {
    return client.delete(`/roles/${roleId}`)
  },
}
