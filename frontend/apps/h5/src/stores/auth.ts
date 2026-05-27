import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { h5Client } from '@/api/client'

export interface H5User {
  id: number
  openid: string
  nickname: string
  avatar: string
  phone: string
  vipLevel: number
  balance: number
  credits: number
}

export const useH5AuthStore = defineStore('h5Auth', () => {
  const token = ref<string>(localStorage.getItem('h5_auth_token') || '')
  const user = ref<H5User | null>(null)

  const isLoggedIn = computed(() => !!token.value)
  const userName = computed(() => user.value?.nickname || '微信用户')

  async function login(code: string): Promise<void> {
    const { data } = await h5Client.post('/auth/wechat', { code })
    token.value = data.token
    user.value = data.user
    localStorage.setItem('h5_auth_token', data.token)
  }

  async function fetchUser(): Promise<void> {
    if (!token.value) return
    try {
      const { data } = await h5Client.get('/user')
      user.value = data
    } catch {
      logout()
    }
  }

  function logout(): void {
    token.value = ''
    user.value = null
    localStorage.removeItem('h5_auth_token')
  }

  function restore(): void {
    const savedToken = localStorage.getItem('h5_auth_token')
    if (savedToken) {
      token.value = savedToken
      fetchUser()
    }
  }

  return {
    token,
    user,
    isLoggedIn,
    userName,
    login,
    fetchUser,
    logout,
    restore,
  }
})
