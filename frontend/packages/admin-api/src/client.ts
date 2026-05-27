import axios from 'axios'
import type { AdminApiError } from '@diandantong/admin-types'

const TOKEN_KEY = 'admin_auth_token'

const client = axios.create({
  baseURL: '/api/admin/v1',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
})

export function setAuthToken(token: string) {
  if (token) {
    client.defaults.headers.common['Authorization'] = `Bearer ${token}`
    localStorage.setItem(TOKEN_KEY, token)
  } else {
    delete client.defaults.headers.common['Authorization']
    localStorage.removeItem(TOKEN_KEY)
  }
}

export function getStoredToken(): string {
  return localStorage.getItem(TOKEN_KEY) || ''
}

client.interceptors.request.use((config) => {
  const token = localStorage.getItem(TOKEN_KEY)
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

client.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      setAuthToken('')
      window.location.href = '/admin/login'
    }

    const apiError: AdminApiError = {
      status: error.response?.status || 0,
      message: error.response?.data?.message || error.message || '请求失败',
      errors: error.response?.data?.errors,
    }
    return Promise.reject(apiError)
  }
)

export default client
