import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { Order, OrderType, OrderStatus } from '@webpos/types'
import { orderApi } from '@webpos/api'

export const useOrderStore = defineStore('order', () => {
  const orders = ref<Order[]>([])
  const currentOrder = ref<Order | null>(null)
  const loading = ref(false)
  const total = ref(0)

  async function fetchOrders(branchId: number, orderType: OrderType, params?: { page?: number; status?: OrderStatus }) {
    loading.value = true
    try {
      const { data } = await orderApi.list(branchId, orderType, params)
      orders.value = data.data
      total.value = data.total
    } finally {
      loading.value = false
    }
  }

  async function fetchOrder(branchId: number, orderType: OrderType, orderId: number) {
    loading.value = true
    try {
      const { data } = await orderApi.get(branchId, orderType, orderId)
      currentOrder.value = data
      return data
    } finally {
      loading.value = false
    }
  }

  async function confirmOrder(branchId: number, orderType: OrderType, orderId: number) {
    const { data } = await orderApi.confirm(branchId, orderType, orderId)
    updateOrderInList(data)
    currentOrder.value = data
    return data
  }

  async function completeOrder(branchId: number, orderType: OrderType, orderId: number) {
    const { data } = await orderApi.complete(branchId, orderType, orderId)
    updateOrderInList(data)
    currentOrder.value = data
    return data
  }

  async function cancelOrder(branchId: number, orderType: OrderType, orderId: number, reason?: string) {
    const { data } = await orderApi.cancel(branchId, orderType, orderId, reason)
    updateOrderInList(data)
    currentOrder.value = data
    return data
  }

  function updateOrderInList(order: Order) {
    const idx = orders.value.findIndex((o) => o.id === order.id)
    if (idx !== -1) orders.value[idx] = order
  }

  return {
    orders,
    currentOrder,
    loading,
    total,
    fetchOrders,
    fetchOrder,
    confirmOrder,
    completeOrder,
    cancelOrder,
  }
})
