import client from '../client'
import type {
  AdminOrder,
  AdminOrderSubtype,
  AdminDeliveryOrder,
  OrderType,
  OrderStatus,
  AdminPaginatedResult,
} from '@diandantong/admin-types'

export interface OrderListParams {
  page?: number
  per_page?: number
  q?: {
    order_type_eq?: OrderType
    status_eq?: OrderStatus
    order_no_cont?: string
    placed_at_gteq?: string
    placed_at_lteq?: string
    [key: string]: unknown
  }
}

export const orderApi = {
  list(params?: OrderListParams) {
    return client.get<AdminPaginatedResult<AdminOrder>>('/orders', { params })
  },

  get(orderId: number) {
    return client.get<AdminOrder>(`/orders/${orderId}`)
  },

  listByType(orderType: OrderType, params?: Omit<OrderListParams, 'q'> & { status?: string; order_no?: string }) {
    const q: Record<string, unknown> = { order_type_eq: orderType }
    if (params?.status) q.status_eq = params.status as OrderStatus
    if (params?.order_no) q.order_no_cont = params.order_no
    return client.get<AdminPaginatedResult<AdminOrderSubtype>>('/orders', {
      params: { page: params?.page, per_page: params?.per_page, q },
    })
  },

  confirm(orderId: number) {
    return client.put<AdminOrder>(`/orders/${orderId}/confirm`)
  },

  cancel(orderId: number, reason?: string) {
    return client.put<AdminOrder>(`/orders/${orderId}/cancel`, { reason })
  },

  complete(orderId: number) {
    return client.put<AdminOrder>(`/orders/${orderId}/complete`)
  },

  refund(orderId: number, reason?: string) {
    return client.post<AdminOrder>(`/orders/${orderId}/refund`, { reason })
  },

  reprint(orderId: number, printerId?: number) {
    return client.post(`/orders/${orderId}/reprint`, { printer_id: printerId })
  },

  // Delivery-specific actions
  delivery: {
    assign(orderId: number, deliveryManId: number) {
      return client.put<AdminDeliveryOrder>(`/delivery_orders/${orderId}/assign`, { delivery_man_id: deliveryManId })
    },
    start(orderId: number) {
      return client.put<AdminDeliveryOrder>(`/delivery_orders/${orderId}/start`)
    },
    ship(orderId: number) {
      return client.put<AdminDeliveryOrder>(`/delivery_orders/${orderId}/ship`)
    },
  },
}
