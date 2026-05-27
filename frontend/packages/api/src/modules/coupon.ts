import client from '../client'
import type { Coupon, Voucher } from '@webpos/types'

export const couponApi = {
  listCoupons(branchId: number, vipInfoId: number) {
    return client.get<Coupon[]>(`/branches/${branchId}/vip_infos/${vipInfoId}/coupons`)
  },

  listVouchers(branchId: number, vipInfoId: number) {
    return client.get<Voucher[]>(`/branches/${branchId}/vip_infos/${vipInfoId}/vouchers`)
  },
}
