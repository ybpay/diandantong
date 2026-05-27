import client from '../client'
import type { AdminPrinter, AdminPaginatedResult } from '@diandantong/admin-types'

export const printerApi = {
  list(params?: { branch_id?: number }) {
    return client.get<AdminPaginatedResult<AdminPrinter>>('/printers', { params })
  },

  create(data: Partial<AdminPrinter>) {
    return client.post<AdminPrinter>('/printers', data)
  },

  update(printerId: number, data: Partial<AdminPrinter>) {
    return client.put<AdminPrinter>(`/printers/${printerId}`, data)
  },

  delete(printerId: number) {
    return client.delete(`/printers/${printerId}`)
  },

  testPrint(printerId: number) {
    return client.post(`/printers/${printerId}/test_print`)
  },
}
