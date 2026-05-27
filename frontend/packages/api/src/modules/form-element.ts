import client from '../client'
import type { FormElement } from '@webpos/types'

export const formElementApi = {
  list(branchId: number) {
    return client.get<FormElement[]>(`/branches/${branchId}/form_elements`)
  },
}
