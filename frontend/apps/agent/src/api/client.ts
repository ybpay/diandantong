import axios from 'axios'

export const agentClient = axios.create({
  baseURL: '/api/agent/v1',
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
  },
})

agentClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('agent_auth_token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

agentClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('agent_auth_token')
      window.location.hash = '#/login'
    }
    return Promise.reject(error)
  }
)
