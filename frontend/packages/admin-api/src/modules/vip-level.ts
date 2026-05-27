import client from '../client'
import type { AdminVipLevel } from '@diandantong/admin-types'

export const vipLevelApi = {
  list() {
    return client.get<AdminVipLevel[]>('/vip_levels')
  },

  create(data: Partial<AdminVipLevel>) {
    return client.post<AdminVipLevel>('/vip_levels', data)
  },

  update(levelId: number, data: Partial<AdminVipLevel>) {
    return client.put<AdminVipLevel>(`/vip_levels/${levelId}`, data)
  },

  delete(levelId: number) {
    return client.delete(`/vip_levels/${levelId}`)
  },
}
