import client from '../client'
import type { AdminShop } from '@diandantong/admin-types'

export const shopApi = {
  getShop() {
    return client.get<AdminShop>('/shop')
  },

  updateShop(data: Partial<AdminShop>) {
    return client.put<AdminShop>('/shop', data)
  },
}
