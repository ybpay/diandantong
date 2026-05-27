import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface CartItem {
  productId: number
  name: string
  price: number
  quantity: number
  image: string
  variants?: string
  branchId: number
}

export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([])

  const totalCount = computed(() =>
    items.value.reduce((sum, item) => sum + item.quantity, 0)
  )

  const totalPrice = computed(() =>
    items.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
  )

  const branchId = computed(() =>
    items.value.length > 0 ? items.value[0].branchId : null
  )

  function addItem(item: CartItem): void {
    const existing = items.value.find(
      (i) =>
        i.productId === item.productId &&
        i.variants === item.variants &&
        i.branchId === item.branchId
    )
    if (existing) {
      existing.quantity += item.quantity
    } else {
      items.value.push({ ...item })
    }
  }

  function removeItem(productId: number, variants?: string): void {
    const index = items.value.findIndex(
      (i) => i.productId === productId && i.variants === variants
    )
    if (index !== -1) {
      items.value.splice(index, 1)
    }
  }

  function updateQuantity(productId: number, quantity: number, variants?: string): void {
    const item = items.value.find(
      (i) => i.productId === productId && i.variants === variants
    )
    if (item) {
      if (quantity <= 0) {
        removeItem(productId, variants)
      } else {
        item.quantity = quantity
      }
    }
  }

  function clear(): void {
    items.value = []
  }

  return {
    items,
    totalCount,
    totalPrice,
    branchId,
    addItem,
    removeItem,
    updateQuantity,
    clear,
  }
})
