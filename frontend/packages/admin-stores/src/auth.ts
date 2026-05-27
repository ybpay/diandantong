import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { AdminUser, AdminShop, AdminLoginParams } from '@diandantong/admin-types'
import { authApi, setAuthToken, getStoredToken } from '@diandantong/admin-api'

export const useAuthStore = defineStore('admin-auth', () => {
  const user = ref<AdminUser | null>(null)
  const shop = ref<AdminShop | null>(null)
  const token = ref<string>('')

  const isLoggedIn = computed(() => !!token.value)
  const userName = computed(() => user.value?.name || '')

  async function login(params: AdminLoginParams) {
    const { data } = await authApi.login(params)
    token.value = data.token
    user.value = data.user
    shop.value = data.shop
    setAuthToken(data.token)
  }

  async function fetchCurrentUser() {
    const { data } = await authApi.getCurrentUser()
    token.value = data.token
    user.value = data.user
    shop.value = data.shop
    setAuthToken(data.token)
  }

  async function logout() {
    try {
      await authApi.logout()
    } finally {
      user.value = null
      shop.value = null
      token.value = ''
      setAuthToken('')
    }
  }

  async function restore() {
    const savedToken = getStoredToken()
    if (savedToken) {
      token.value = savedToken
      setAuthToken(savedToken)
      try {
        await fetchCurrentUser()
      } catch {
        await logout()
      }
    }
  }

  return {
    user,
    shop,
    token,
    isLoggedIn,
    userName,
    login,
    logout,
    restore,
    fetchCurrentUser,
  }
})
