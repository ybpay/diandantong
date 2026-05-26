import client from '../client'
import type { Table, TableZone } from '@webpos/types'

export const tableApi = {
  listZones(branchId: number) {
    return client.get<TableZone[]>(`/branches/${branchId}/table_zones`)
  },

  listTables(branchId: number, zoneId?: number) {
    const params = zoneId ? { zone_id: zoneId } : {}
    return client.get<Table[]>(`/branches/${branchId}/tables`, { params })
  },

  getTable(branchId: number, tableId: number) {
    return client.get<Table>(`/branches/${branchId}/tables/${tableId}`)
  },
}
