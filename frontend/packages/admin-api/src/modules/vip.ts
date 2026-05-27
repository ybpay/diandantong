import client from '../client'
import type { AdminVipInfo, AdminPaginatedResult } from '@diandantong/admin-types'

export const vipApi = {
  list(params?: { page?: number; per_page?: number; keyword?: string }) {
    return client.get<AdminPaginatedResult<AdminVipInfo>>('/vips', { params })
  },

  get(vipId: number) {
    return client.get<AdminVipInfo>(`/vips/${vipId}`)
  },

  create(data: Partial<AdminVipInfo>) {
    return client.post<AdminVipInfo>('/vips', data)
  },

  update(vipId: number, data: Partial<AdminVipInfo>) {
    return client.put<AdminVipInfo>(`/vips/${vipId}`, data)
  },

  sendCoupon(vipId: number, couponId: number) {
    return client.post(`/vips/${vipId}/send_coupon`, { coupon_id: couponId })
  },

  rechargeWallet(vipId: number, amount: number, paymentMethod: string) {
    return client.post(`/vips/${vipId}/recharge`, { amount, payment_method: paymentMethod })
  },
}
