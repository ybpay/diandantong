# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 NotificationSetting', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/notification_setting' do
    it 'returns notification setting' do
      get '/api/admin/v1/notification_setting', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns notification setting for specific account' do
      account = create(:account, shop: shop)
      get "/api/admin/v1/notification_setting?account_id=#{account.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/notification_setting'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/notification_setting' do
    it 'updates notification setting' do
      patch '/api/admin/v1/notification_setting', params: {
        notification_receive_setting: { new_order: true, order_cancelled: false }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      patch '/api/admin/v1/notification_setting', params: { notification_receive_setting: { new_order: true } }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
