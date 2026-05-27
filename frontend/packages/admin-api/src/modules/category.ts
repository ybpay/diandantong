import client from '../client'
import type { AdminCategory } from '@diandantong/admin-types'

export const categoryApi = {
  list() {
    return client.get<AdminCategory[]>('/categories')
  },

  create(data: Partial<AdminCategory>) {
    return client.post<AdminCategory>('/categories', data)
  },

  update(categoryId: number, data: Partial<AdminCategory>) {
    return client.put<AdminCategory>(`/categories/${categoryId}`, data)
  },

  delete(categoryId: number) {
    return client.delete(`/categories/${categoryId}`)
  },

  sort(orders: { id: number; sort_order: number; parent_id: number | null }[]) {
    return client.post('/categories/sort', { orders })
  },
}
