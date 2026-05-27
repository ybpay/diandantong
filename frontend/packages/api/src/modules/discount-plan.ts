import client from '../client'
import type { DiscountPlan } from '@webpos/types'

export const discountPlanApi = {
  list(branchId: number) {
    return client.get<DiscountPlan[]>(`/branches/${branchId}/discount_plans`)
  },
}
