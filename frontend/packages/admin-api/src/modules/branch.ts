import client from '../client'
import type { AdminBranch, AdminPaginatedResult } from '@diandantong/admin-types'

export const branchApi = {
  list(params?: { page?: number; per_page?: number }) {
    return client.get<AdminPaginatedResult<AdminBranch>>('/branches', { params })
  },

  get(branchId: number) {
    return client.get<AdminBranch>(`/branches/${branchId}`)
  },

  create(data: Partial<AdminBranch>) {
    return client.post<AdminBranch>('/branches', data)
  },

  update(branchId: number, data: Partial<AdminBranch>) {
    return client.put<AdminBranch>(`/branches/${branchId}`, data)
  },

  delete(branchId: number) {
    return client.delete(`/branches/${branchId}`)
  },
}
