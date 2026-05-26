import client from '../client'
import type { Statistic } from '@webpos/types'

export const statisticApi = {
  getDaily(branchId: number, date: string) {
    return client.get<Statistic>(`/branches/${branchId}/statistics`, { params: { date } })
  },

  getRange(branchId: number, startDate: string, endDate: string) {
    return client.get<Statistic[]>(`/branches/${branchId}/statistics/range`, {
      params: { start_date: startDate, end_date: endDate },
    })
  },
}
