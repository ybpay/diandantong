import axios from 'axios'
import type { ApiError } from '@webpos/types'

const client = axios.create({
  baseURL: '/api/v3',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
})

let terminalId = ''
let authorizerToken = ''

export function setTerminalId(id: string) {
  terminalId = id
}

export function setAuthorizerToken(token: string) {
  authorizerToken = token
  if (token) {
    client.defaults.headers.common['Authorization'] = `Bearer ${token}`
  } else {
    delete client.defaults.headers.common['Authorization']
  }
}

client.interceptors.request.use((config) => {
  if (terminalId) {
    config.params = { ...config.params, terminal_id: terminalId }
  }
  return config
})

client.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      setAuthorizerToken('')
      window.location.href = '/#/sign_in'
    }

    const apiError: ApiError = {
      status: error.response?.status || 0,
      message: error.response?.data?.message || error.message || '请求失败',
      errors: error.response?.data?.errors,
    }
    return Promise.reject(apiError)
  }
)

export default client
