import client from '../client'
import type { Shop, Branch } from '@webpos/types'

export const shopApi = {
  getShop() {
    return client.get<Shop>('/shop')
  },

  getBranches() {
    return client.get<Branch[]>('/branches')
  },

  getBranch(branchId: number) {
    return client.get<Branch>(`/branches/${branchId}`)
  },
}
