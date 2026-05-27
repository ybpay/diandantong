import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { Cart, CartItem, OrderType } from '@webpos/types'
import { cartApi } from '@webpos/api'

export const useCartStore = defineStore('cart', () => {
  const carts = ref<Map<string, Cart>>(new Map())

  function cartKey(branchId: number, orderType: OrderType) {
    return `${branchId}:${orderType}`
  }

  function getCart(branchId: number, orderType: OrderType) {
    return carts.value.get(cartKey(branchId, orderType))
  }

  const totalItems = computed(() => {
    let count = 0
    for (const cart of carts.value.values()) {
      count += cart.items.reduce((sum, item) => sum + item.quantity, 0)
    }
    return count
  })

  async function fetchCart(branchId: number, orderType: OrderType) {
    const { data } = await cartApi.get(branchId, orderType)
    carts.value.set(cartKey(branchId, orderType), data)
    return data
  }

  async function addItem(branchId: number, orderType: OrderType, item: CartItem) {
    const { data } = await cartApi.addItem(branchId, orderType, item)
    carts.value.set(cartKey(branchId, orderType), data)
    return data
  }

  async function addSeparateItem(branchId: number, orderType: OrderType, item: CartItem) {
    const { data } = await cartApi.addSeparateItem(branchId, orderType, item)
    carts.value.set(cartKey(branchId, orderType), data)
    return data
  }

  async function removeItem(branchId: number, orderType: OrderType, itemId: number) {
    const { data } = await cartApi.removeItem(branchId, orderType, itemId)
    carts.value.set(cartKey(branchId, orderType), data)
    return data
  }

  async function updateItem(branchId: number, orderType: OrderType, item: CartItem) {
    const { data } = await cartApi.updateItem(branchId, orderType, item)
    carts.value.set(cartKey(branchId, orderType), data)
    return data
  }

  async function changeNote(branchId: number, orderType: OrderType, itemId: number, note: string) {
    const { data } = await cartApi.changeNote(branchId, orderType, itemId, note)
    carts.value.set(cartKey(branchId, orderType), data)
    return data
  }

  async function placeCart(branchId: number, orderType: OrderType, params: Record<string, unknown>) {
    await cartApi.place(branchId, orderType, params)
    carts.value.delete(cartKey(branchId, orderType))
  }

  async function clearCart(branchId: number, orderType: OrderType) {
    await cartApi.clear(branchId, orderType)
    carts.value.delete(cartKey(branchId, orderType))
  }

  return {
    carts,
    totalItems,
    getCart,
    fetchCart,
    addItem,
    addSeparateItem,
    removeItem,
    updateItem,
    changeNote,
    placeCart,
    clearCart,
  }
})
