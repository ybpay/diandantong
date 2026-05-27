import client from '../client'
import type { AdminCombo, AdminPaginatedResult } from '@diandantong/admin-types'

export const comboApi = {
  list(params?: { page?: number; per_page?: number }) {
    return client.get<AdminPaginatedResult<AdminCombo>>('/combos', { params })
  },

  get(comboId: number) {
    return client.get<AdminCombo>(`/combos/${comboId}`)
  },

  create(data: Partial<AdminCombo>) {
    return client.post<AdminCombo>('/combos', data)
  },

  update(comboId: number, data: Partial<AdminCombo>) {
    return client.put<AdminCombo>(`/combos/${comboId}`, data)
  },

  delete(comboId: number) {
    return client.delete(`/combos/${comboId}`)
  },
}
