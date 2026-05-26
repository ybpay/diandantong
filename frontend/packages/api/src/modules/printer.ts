import client from '../client'
import type { Printer } from '@webpos/types'

export const printerApi = {
  list(branchId: number) {
    return client.get<Printer[]>(`/branches/${branchId}/printers`)
  },

  reprint(branchId: number, printerIds: number[], note: string, orderId?: number) {
    return client.post(`/branches/${branchId}/printers/reprint`, {
      printer_ids: printerIds,
      note,
      order_id: orderId,
    })
  },

  getStates(branchId: number) {
    return client.get(`/branches/${branchId}/printers/get_states`)
  },

  testPrint(branchId: number, printerId: number) {
    return client.post(`/branches/${branchId}/printers/test_print`, { printer_id: printerId })
  },

  testPrintAll(branchId: number) {
    return client.post(`/branches/${branchId}/printers/test_print_all`)
  },
}
