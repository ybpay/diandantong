import client from '../client'
import type { AdminVoucher, AdminPaginatedResult } from '@diandantong/admin-types'

export const voucherApi = {
  list(params?: { page?: number; per_page?: number; status?: string }) {
    return client.get<AdminPaginatedResult<AdminVoucher>>('/vouchers', { params })
  },

  create(data: Partial<AdminVoucher>) {
    return client.post<AdminVoucher>('/vouchers', data)
  },

  update(voucherId: number, data: Partial<AdminVoucher>) {
    return client.put<AdminVoucher>(`/vouchers/${voucherId}`, data)
  },

  delete(voucherId: number) {
    return client.delete(`/vouchers/${voucherId}`)
  },
}
