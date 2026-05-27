import axios from 'axios'

export const h5Client = axios.create({
  baseURL: '/api/h5/v1',
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
  },
})

h5Client.interceptors.request.use((config) => {
  const token = localStorage.getItem('h5_auth_token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

h5Client.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('h5_auth_token')
      window.location.hash = '#/auth'
    }
    return Promise.reject(error)
  }
)
