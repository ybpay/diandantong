import client from '../client'
import type { Cart, CartItem, OrderType } from '@webpos/types'

const cartPathMap: Record<OrderType, string> = {
  eat_in_hall: 'table_carts',
  fast_food: 'fastfood_carts',
  delivery: 'delivery_carts',
  reservation: 'reservation_carts',
  payment: 'payment_carts',
  groupon: 'groupon_carts',
  recharge: 'recharge_carts',
}

function getCartPath(orderType: OrderType) {
  return cartPathMap[orderType]
}

export const cartApi = {
  get(branchId: number, orderType: OrderType, cartId?: number) {
    const base = `/branches/${branchId}/${getCartPath(orderType)}`
    if (cartId) return client.get<Cart>(`${base}/${cartId}`)
    return client.get<Cart>(base)
  },

  addItem(branchId: number, orderType: OrderType, item: CartItem) {
    return client.post<Cart>(`/branches/${branchId}/${getCartPath(orderType)}/add_item`, { item })
  },

  addSeparateItem(branchId: number, orderType: OrderType, item: CartItem) {
    return client.post<Cart>(`/branches/${branchId}/${getCartPath(orderType)}/add_separate_item`, { item })
  },

  removeItem(branchId: number, orderType: OrderType, itemId: number) {
    return client.post<Cart>(`/branches/${branchId}/${getCartPath(orderType)}/remove_item`, { item_id: itemId })
  },

  updateItem(branchId: number, orderType: OrderType, item: CartItem) {
    return client.post<Cart>(`/branches/${branchId}/${getCartPath(orderType)}/update_item`, { item })
  },

  changeNote(branchId: number, orderType: OrderType, itemId: number, note: string) {
    return client.post<Cart>(`/branches/${branchId}/${getCartPath(orderType)}/change_note`, { item_id: itemId, note })
  },

  place(branchId: number, orderType: OrderType, params: Record<string, unknown>) {
    return client.post(`/branches/${branchId}/${getCartPath(orderType)}/place`, params)
  },

  clear(branchId: number, orderType: OrderType) {
    return client.post(`/branches/${branchId}/${getCartPath(orderType)}/clear`)
  },
}
