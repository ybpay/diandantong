import client from '../client'

export interface PaymentSettings {
  wechat_pay_enabled: boolean
  alipay_enabled: boolean
  card_enabled: boolean
  wechat_mch_id: string
  alipay_app_id: string
}

export interface PaymentSettingsUpdate extends PaymentSettings {
  wechat_mch_key?: string
  alipay_private_key?: string
}

export const paymentApi = {
  getSettings() {
    return client.get<PaymentSettings>('/payment/settings')
  },

  updateSettings(data: Partial<PaymentSettingsUpdate>) {
    return client.put<PaymentSettings>('/payment/settings', data)
  },
}
