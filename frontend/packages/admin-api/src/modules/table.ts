import client from '../client'
import type { AdminTable, AdminTableZone } from '@diandantong/admin-types'

export const tableApi = {
  listZones(params?: { branch_id?: number }) {
    return client.get<AdminTableZone[]>('/table_zones', { params })
  },

  createZone(data: Partial<AdminTableZone>) {
    return client.post<AdminTableZone>('/table_zones', { table_zone: data })
  },

  updateZone(zoneId: number, data: Partial<AdminTableZone>) {
    return client.put<AdminTableZone>(`/table_zones/${zoneId}`, { table_zone: data })
  },

  deleteZone(zoneId: number) {
    return client.delete(`/table_zones/${zoneId}`)
  },

  listTables(params?: { zone_id?: number; branch_id?: number }) {
    return client.get<AdminTable[]>('/tables', { params })
  },

  createTable(data: Partial<AdminTable>) {
    return client.post<AdminTable>('/tables', { table: data })
  },

  updateTable(tableId: number, data: Partial<AdminTable>) {
    return client.put<AdminTable>(`/tables/${tableId}`, { table: data })
  },

  deleteTable(tableId: number) {
    return client.delete(`/tables/${tableId}`)
  },
}
