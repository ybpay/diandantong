import client from '../client'

export interface WeChatSettings {
  app_id: string
  mch_id: string
  notify_url: string
}

export interface WeChatSettingsUpdate extends WeChatSettings {
  app_secret?: string
  mch_key?: string
}

export interface WeChatMenu {
  button: WeChatMenuItem[]
}

export interface WeChatMenuItem {
  name: string
  type?: string
  key?: string
  url?: string
  sub_button?: WeChatMenuItem[]
}

export const wechatApi = {
  getSettings() {
    return client.get<WeChatSettings>('/wechat/settings')
  },

  updateSettings(data: Partial<WeChatSettingsUpdate>) {
    return client.put<WeChatSettings>('/wechat/settings', data)
  },

  menus() {
    return client.get<WeChatMenu>('/wechat/menus')
  },
}
