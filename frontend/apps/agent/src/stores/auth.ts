import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { agentClient } from '@/api/client'

export interface AgentUser {
  id: number
  name: string
  email: string
  phone: string
  role: string
  avatar: string
}

export const useAgentAuthStore = defineStore('agentAuth', () => {
  const token = ref<string>(localStorage.getItem('agent_auth_token') || '')
  const user = ref<AgentUser | null>(null)

  const isLoggedIn = computed(() => !!token.value)
  const userName = computed(() => user.value?.name || '代理商')

  async function login(email: string, password: string): Promise<void> {
    const { data } = await agentClient.post('/auth/login', { email, password })
    token.value = data.token
    user.value = data.user
    localStorage.setItem('agent_auth_token', data.token)
  }

  async function fetchUser(): Promise<void> {
    if (!token.value) return
    try {
      const { data } = await agentClient.get('/user')
      user.value = data
    } catch {
      logout()
    }
  }

  function logout(): void {
    token.value = ''
    user.value = null
    localStorage.removeItem('agent_auth_token')
  }

  function restore(): void {
    const savedToken = localStorage.getItem('agent_auth_token')
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
