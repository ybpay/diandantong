import client from '../client'
import type { AdminKitchenSetting } from '@diandantong/admin-types'

export const kitchenSettingApi = {
  get(params?: { branch_id?: number }) {
    return client.get<AdminKitchenSetting>('/kitchen_setting', { params })
  },

  update(data: Partial<AdminKitchenSetting>, params?: { branch_id?: number }) {
    return client.put<AdminKitchenSetting>('/kitchen_setting', { kitchen_setting: data }, { params })
  },
}
