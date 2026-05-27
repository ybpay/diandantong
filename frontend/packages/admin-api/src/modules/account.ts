import client from '../client'
import type { AdminUser, AdminPaginatedResult } from '@diandantong/admin-types'

export const accountApi = {
  list(params?: { page?: number; per_page?: number; keyword?: string }) {
    return client.get<AdminPaginatedResult<AdminUser>>('/accounts', { params })
  },

  create(data: Partial<AdminUser>) {
    return client.post<AdminUser>('/accounts', data)
  },

  update(accountId: number, data: Partial<AdminUser>) {
    return client.put<AdminUser>(`/accounts/${accountId}`, data)
  },

  delete(accountId: number) {
    return client.delete(`/accounts/${accountId}`)
  },
}
