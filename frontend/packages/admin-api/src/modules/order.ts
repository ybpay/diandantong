import client from '../client'
import type { AdminOrder, OrderType, AdminPaginatedResult } from '@diandantong/admin-types'

export const orderApi = {
  list(params?: { page?: number; per_page?: number; status?: string; order_type?: OrderType; start_date?: string; end_date?: string }) {
    return client.get<AdminPaginatedResult<AdminOrder>>('/orders', { params })
  },

  get(orderId: number) {
    return client.get<AdminOrder>(`/orders/${orderId}`)
  },

  listByType(orderType: OrderType, params?: { page?: number; per_page?: number; status?: string }) {
    return client.get<AdminPaginatedResult<AdminOrder>>(`/orders`, { params: { ...params, order_type: orderType } })
  },

  cancel(orderId: number, reason?: string) {
    return client.post<AdminOrder>(`/orders/${orderId}/cancel`, { reason })
  },

  refund(orderId: number, reason?: string) {
    return client.post<AdminOrder>(`/orders/${orderId}/refund`, { reason })
  },

  reprint(orderId: number, printerId?: number) {
    return client.post(`/orders/${orderId}/reprint`, { printer_id: printerId })
  },
}
