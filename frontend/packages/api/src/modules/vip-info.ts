import client from '../client'
import type { VipInfo, PaginatedResult } from '@webpos/types'

export const vipInfoApi = {
  list(branchId: number, params?: { page?: number; per_page?: number; keyword?: string }) {
    return client.get<PaginatedResult<VipInfo>>(`/branches/${branchId}/vip_infos`, { params })
  },

  get(vipInfoId: number) {
    return client.get<VipInfo>(`/vip_infos/${vipInfoId}`)
  },

  search(keyword: string) {
    return client.get<VipInfo[]>('/vip_infos/search', { params: { keyword } })
  },
}
