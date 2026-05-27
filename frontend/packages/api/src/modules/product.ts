import client from '../client'
import type { Product, PaginatedResult } from '@webpos/types'

export const productApi = {
  list(branchId: number, params?: { category_id?: number; page?: number; per_page?: number }) {
    return client.get<PaginatedResult<Product>>(`/branches/${branchId}/products`, { params })
  },

  get(branchId: number, productId: number) {
    return client.get<Product>(`/branches/${branchId}/products/${productId}`)
  },

  listCategories(branchId: number) {
    return client.get(`/branches/${branchId}/product_categories`)
  },
}
