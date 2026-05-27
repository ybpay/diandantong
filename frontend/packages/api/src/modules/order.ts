import client from '../client'
import type { Order, OrderType, PayItem, PaginatedResult } from '@webpos/types'

const orderPathMap: Record<OrderType, string> = {
  eat_in_hall: 'eat_in_hall_orders',
  fast_food: 'fastfood_orders',
  delivery: 'delivery_orders',
  reservation: 'reservation_orders',
  payment: 'payment_orders',
  groupon: 'groupon_orders',
  recharge: 'recharge_orders',
}

function getOrdersPath(orderType: OrderType) {
  return orderPathMap[orderType]
}

export const orderApi = {
  list(branchId: number, orderType: OrderType, params?: { page?: number; per_page?: number; status?: string }) {
    return client.get<PaginatedResult<Order>>(
      `/branches/${branchId}/${getOrdersPath(orderType)}`,
      { params }
    )
  },

  get(branchId: number, orderType: OrderType, orderId: number) {
    return client.get<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}`)
  },

  confirm(branchId: number, orderType: OrderType, orderId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/confirm`)
  },

  complete(branchId: number, orderType: OrderType, orderId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/complete`)
  },

  cancel(branchId: number, orderType: OrderType, orderId: number, reason?: string) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/cancel`, { reason })
  },

  append(branchId: number, orderType: OrderType, orderId: number, lineItems: unknown[]) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/append`, { line_items: lineItems })
  },

  subtract(branchId: number, orderType: OrderType, orderId: number, lineItemId: number, quantity: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/subtract`, { line_item_id: lineItemId, quantity })
  },

  activeLineItems(branchId: number, orderType: OrderType, orderId: number) {
    return client.get(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/active_line_items`)
  },

  changeVipInfo(branchId: number, orderType: OrderType, orderId: number, vipInfoId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/change_vip_info`, { vip_info_id: vipInfoId })
  },

  unbindVipInfo(branchId: number, orderType: OrderType, orderId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/unbind_vip_info`)
  },

  privilegeDiscount(branchId: number, orderType: OrderType, orderId: number, amount: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/privilege_discount`, { amount })
  },

  privilegeReduction(branchId: number, orderType: OrderType, orderId: number, amount: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/privilege_reduction`, { amount })
  },

  privilegeFree(branchId: number, orderType: OrderType, orderId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/privilege_free`)
  },

  moling(branchId: number, orderType: OrderType, orderId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/moling`)
  },

  cancelMoling(branchId: number, orderType: OrderType, orderId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/cancel_moling`)
  },

  applyCoupon(branchId: number, orderType: OrderType, orderId: number, couponId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/apply_coupon`, { coupon_id: couponId })
  },

  clearCoupon(branchId: number, orderType: OrderType, orderId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/clear_coupon`)
  },

  applyVoucher(branchId: number, orderType: OrderType, orderId: number, voucherId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/apply_voucher`, { voucher_id: voucherId })
  },

  rollbackVoucher(branchId: number, orderType: OrderType, orderId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/rollback_voucher`)
  },

  bill(branchId: number, orderType: OrderType, orderId: number, payItems: PayItem[]) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/bill`, { pay_items: payItems })
  },

  createPayItems(branchId: number, orderType: OrderType, orderId: number, payItems: PayItem[]) {
    return client.post(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/create_pay_items`, { pay_items: payItems })
  },

  clearPayItems(branchId: number, orderType: OrderType, orderId: number) {
    return client.post(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/clear_pay_items`)
  },

  payAllPayItems(branchId: number, orderType: OrderType, orderId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/pay_all_pay_items`)
  },

  addDiscountPlan(branchId: number, orderType: OrderType, orderId: number, discountPlanId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/add_discount_plan`, { discount_plan_id: discountPlanId })
  },

  cancelDiscountPlan(branchId: number, orderType: OrderType, orderId: number) {
    return client.post<Order>(`/branches/${branchId}/${getOrdersPath(orderType)}/${orderId}/cancel_discount_plan`)
  },

  // Eat-in-hall specific
  changeTable(branchId: number, orderId: number, tableId: number) {
    return client.post(`/branches/${branchId}/eat_in_hall_orders/${orderId}/change_table`, { table_id: tableId })
  },

  mergeTable(branchId: number, orderId: number, tableIds: number[]) {
    return client.post(`/branches/${branchId}/eat_in_hall_orders/${orderId}/merge_table`, { table_ids: tableIds })
  },

  moveItemable(branchId: number, orderId: number, targetTableId: number) {
    return client.post(`/branches/${branchId}/eat_in_hall_orders/${orderId}/move_itemable`, { target_table_id: targetTableId })
  },

  bindReservationOrder(branchId: number, orderId: number, reservationOrderId: number) {
    return client.post(`/branches/${branchId}/eat_in_hall_orders/${orderId}/bind_reservation_order`, { reservation_order_id: reservationOrderId })
  },

  antiSettlement(branchId: number, orderId: number) {
    return client.post(`/branches/${branchId}/eat_in_hall_orders/${orderId}/anti_settlement`)
  },

  updateGuestNum(branchId: number, orderId: number, guestNum: number) {
    return client.post(`/branches/${branchId}/eat_in_hall_orders/${orderId}/update_guest_num`, { guest_num: guestNum })
  },

  // Delivery specific
  assignDeliveryMan(branchId: number, orderId: number, deliveryManId: number) {
    return client.post(`/branches/${branchId}/delivery_orders/${orderId}/assign_delivery_man`, { delivery_man_id: deliveryManId })
  },

  // Reservation specific
  changeToEatInHall(branchId: number, orderId: number) {
    return client.post(`/branches/${branchId}/reservation_orders/${orderId}/change_to_eat_in_hall`)
  },

  bindTable(branchId: number, orderId: number, tableId: number) {
    return client.post(`/branches/${branchId}/reservation_orders/${orderId}/bind_table`, { table_id: tableId })
  },

  editReservationInfo(branchId: number, orderId: number, info: unknown) {
    return client.post(`/branches/${branchId}/reservation_orders/${orderId}/edit_reservation_info`, info)
  },

  // Recharge specific
  initRefund(branchId: number, orderId: number) {
    return client.post(`/branches/${branchId}/recharge_orders/${orderId}/init_refund`)
  },
}
