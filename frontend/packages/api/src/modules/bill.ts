import client from '../client'
import type { BillCenter } from '@webpos/types'

export const billApi = {
  getDailyBill(branchId: number, date: string) {
    return client.get<BillCenter>(`/branches/${branchId}/bill_center`, { params: { date } })
  },

  getBillRange(branchId: number, startDate: string, endDate: string) {
    return client.get<BillCenter[]>(`/branches/${branchId}/bill_center/range`, {
      params: { start_date: startDate, end_date: endDate },
    })
  },
}
