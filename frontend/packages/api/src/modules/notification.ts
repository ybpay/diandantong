import client from '../client'
import type { Notification } from '@webpos/types'

export const notificationApi = {
  list(branchId: number) {
    return client.get<Notification[]>(`/branches/${branchId}/notifications`)
  },

  markRead(branchId: number, notificationId: string) {
    return client.post(`/branches/${branchId}/notifications/${notificationId}/mark_read`)
  },

  clear(branchId: number) {
    return client.post(`/branches/${branchId}/notifications/clear`)
  },
}
