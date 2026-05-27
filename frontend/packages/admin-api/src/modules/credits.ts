import client from '../client'
import type { AdminCreditsSetting } from '@diandantong/admin-types'

export const creditsApi = {
  getSettings() {
    return client.get<AdminCreditsSetting>('/credits_settings')
  },

  updateSettings(data: Partial<AdminCreditsSetting>) {
    return client.put<AdminCreditsSetting>('/credits_settings', data)
  },
}
