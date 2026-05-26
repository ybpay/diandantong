import client from '../client'
import type { LoginParams, LoginResult } from '@webpos/types'

export const authApi = {
  login(params: LoginParams) {
    return client.post<LoginResult>('/sessions', params)
  },

  logout() {
    return client.delete('/sessions')
  },

  getCurrentUser() {
    return client.get<LoginResult>('/sessions/current')
  },
}
