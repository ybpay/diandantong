import client from '../client'
import type { AdminProduct, AdminPaginatedResult } from '@diandantong/admin-types'

export const productApi = {
  list(params?: { category_id?: number; page?: number; per_page?: number; keyword?: string }) {
    return client.get<AdminPaginatedResult<AdminProduct>>('/products', { params })
  },

  get(productId: number) {
    return client.get<AdminProduct>(`/products/${productId}`)
  },

  create(data: Partial<AdminProduct>) {
    return client.post<AdminProduct>('/products', data)
  },

  update(productId: number, data: Partial<AdminProduct>) {
    return client.put<AdminProduct>(`/products/${productId}`, data)
  },

  delete(productId: number) {
    return client.delete(`/products/${productId}`)
  },

  toggleSoldOut(productId: number, soldOut: boolean) {
    return client.post<AdminProduct>(`/products/${productId}/toggle_sold_out`, { is_sold_out: soldOut })
  },
}
