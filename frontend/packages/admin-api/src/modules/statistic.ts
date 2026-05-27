import client from '../client'
import type { AdminStatistic } from '@diandantong/admin-types'

export const statisticApi = {
  business(params: { branch_id?: number; start_date: string; end_date: string }) {
    return client.get<AdminStatistic[]>('/statistics/business', { params })
  },

  orders(params: { branch_id?: number; start_date: string; end_date: string }) {
    return client.get<AdminStatistic[]>('/statistics/orders', { params })
  },

  products(params: { branch_id?: number; start_date: string; end_date: string }) {
    return client.get<AdminStatistic[]>('/statistics/products', { params })
  },

  finance(params: { branch_id?: number; start_date: string; end_date: string }) {
    return client.get<AdminStatistic[]>('/statistics/finance', { params })
  },

  coupons(params: { branch_id?: number; start_date: string; end_date: string }) {
    return client.get<AdminStatistic[]>('/statistics/coupons', { params })
  },

  workers(params: { branch_id?: number; start_date: string; end_date: string }) {
    return client.get<AdminStatistic[]>('/statistics/workers', { params })
  },
}
