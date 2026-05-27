import client from '../client'
import type { AdminCouponVersion, AdminPaginatedResult } from '@diandantong/admin-types'

export const couponVersionApi = {
  list(params?: { page?: number; per_page?: number }) {
    return client.get<AdminPaginatedResult<AdminCouponVersion>>('/coupon_versions', { params })
  },

  create(data: Partial<AdminCouponVersion>) {
    return client.post<AdminCouponVersion>('/coupon_versions', data)
  },

  update(versionId: number, data: Partial<AdminCouponVersion>) {
    return client.put<AdminCouponVersion>(`/coupon_versions/${versionId}`, data)
  },
}
