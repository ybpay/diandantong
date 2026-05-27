import client from '../client'
import type { AdminLoginParams, AdminLoginResult } from '@diandantong/admin-types'

export const authApi = {
  login(params: AdminLoginParams) {
    return client.post<AdminLoginResult>('/auth/login', params)
  },

  logout() {
    return client.post('/auth/logout')
  },

  getCurrentUser() {
    return client.get<AdminLoginResult>('/auth/me')
  },
}
