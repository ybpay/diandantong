import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User, Shop, Branch, LoginParams } from '@webpos/types'
import { authApi, setAuthorizerToken, shopApi } from '@webpos/api'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const shop = ref<Shop | null>(null)
  const currentBranch = ref<Branch | null>(null)
  const token = ref<string>('')

  const isLoggedIn = computed(() => !!token.value)
  const userName = computed(() => user.value?.name || '')

  async function login(params: LoginParams) {
    const { data } = await authApi.login(params)
    token.value = data.token
    user.value = data.user
    shop.value = data.shop
    setAuthorizerToken(data.token)
    persist()
  }

  async function fetchCurrentUser() {
    const { data } = await authApi.getCurrentUser()
    token.value = data.token
    user.value = data.user
    shop.value = data.shop
    setAuthorizerToken(data.token)
  }

  function selectBranch(branch: Branch) {
    currentBranch.value = branch
    localStorage.setItem('current_branch_id', String(branch.id))
  }

  async function restoreBranch() {
    const branchId = localStorage.getItem('current_branch_id')
    if (branchId && shop.value) {
      const branch = shop.value.branches.find((b) => String(b.id) === branchId)
      if (branch) currentBranch.value = branch
    }
  }

  async function logout() {
    try {
      await authApi.logout()
    } finally {
      user.value = null
      shop.value = null
      currentBranch.value = null
      token.value = ''
      setAuthorizerToken('')
      localStorage.removeItem('auth_token')
      localStorage.removeItem('current_branch_id')
    }
  }

  function persist() {
    if (token.value) localStorage.setItem('auth_token', token.value)
  }

  async function restore() {
    const savedToken = localStorage.getItem('auth_token')
    if (savedToken) {
      token.value = savedToken
      setAuthorizerToken(savedToken)
      try {
        await fetchCurrentUser()
        await restoreBranch()
      } catch {
        await logout()
      }
    }
  }

  return {
    user,
    shop,
    currentBranch,
    token,
    isLoggedIn,
    userName,
    login,
    logout,
    restore,
    selectBranch,
    fetchCurrentUser,
  }
})
