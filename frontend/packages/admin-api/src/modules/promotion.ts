import client from '../client'
import type { AdminPromotion, AdminPaginatedResult } from '@diandantong/admin-types'

export const promotionApi = {
  list(params?: { page?: number; per_page?: number }) {
    return client.get<AdminPaginatedResult<AdminPromotion>>('/promotions', { params })
  },

  get(promotionId: number) {
    return client.get<AdminPromotion>(`/promotions/${promotionId}`)
  },

  create(data: Partial<AdminPromotion>) {
    return client.post<AdminPromotion>('/promotions', data)
  },

  update(promotionId: number, data: Partial<AdminPromotion>) {
    return client.put<AdminPromotion>(`/promotions/${promotionId}`, data)
  },

  delete(promotionId: number) {
    return client.delete(`/promotions/${promotionId}`)
  },
}
