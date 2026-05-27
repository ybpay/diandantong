import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { AdminShop } from '@diandantong/admin-types'
import { shopApi } from '@diandantong/admin-api'

export const useShopStore = defineStore('admin-shop', () => {
  const shop = ref<AdminShop | null>(null)
  const loading = ref(false)

  async function fetchShop() {
    loading.value = true
    try {
      const { data } = await shopApi.getShop()
      shop.value = data
    } finally {
      loading.value = false
    }
  }

  async function updateShop(updateData: Partial<AdminShop>) {
    const { data } = await shopApi.updateShop(updateData)
    shop.value = data
    return data
  }

  return {
    shop,
    loading,
    fetchShop,
    updateShop,
  }
})
