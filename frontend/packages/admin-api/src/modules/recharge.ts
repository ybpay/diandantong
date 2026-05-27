import client from '../client'
import type { AdminRechargeProduct } from '@diandantong/admin-types'

export const rechargeApi = {
  listProducts() {
    return client.get<AdminRechargeProduct[]>('/recharge_products')
  },

  createProduct(data: Partial<AdminRechargeProduct>) {
    return client.post<AdminRechargeProduct>('/recharge_products', data)
  },

  updateProduct(productId: number, data: Partial<AdminRechargeProduct>) {
    return client.put<AdminRechargeProduct>(`/recharge_products/${productId}`, data)
  },
}
