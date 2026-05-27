import client from '../client'
import type { AdminCoupon, AdminPaginatedResult } from '@diandantong/admin-types'

export const couponApi = {
  list(params?: { page?: number; per_page?: number; status?: string }) {
    return client.get<AdminPaginatedResult<AdminCoupon>>('/coupons', { params })
  },

  create(data: Partial<AdminCoupon>) {
    return client.post<AdminCoupon>('/coupons', data)
  },

  update(couponId: number, data: Partial<AdminCoupon>) {
    return client.put<AdminCoupon>(`/coupons/${couponId}`, data)
  },

  delete(couponId: number) {
    return client.delete(`/coupons/${couponId}`)
  },
}
