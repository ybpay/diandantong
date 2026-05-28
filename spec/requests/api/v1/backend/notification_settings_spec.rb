# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend NotificationSettings', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/system/notification_settings/:account_id' do
    before do
      Ddt::NotificationReceiveSetting.find_or_create_by!(account: boss, shop: shop)
    end

    it 'returns notification setting' do
      get "/api/v1/backend/shops/#{shop.slug}/system/notification_settings/#{boss.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/system/notification_settings/#{boss.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/system/notification_settings/:account_id' do
    before do
      Ddt::NotificationReceiveSetting.find_or_create_by!(account: boss, shop: shop)
    end

    it 'updates notification setting' do
      patch "/api/v1/backend/shops/#{shop.slug}/system/notification_settings/#{boss.id}",
            params: { notification_receive_setting: { new_order: true, order_cancel: false } },
            headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 422 with invalid params' do
      patch "/api/v1/backend/shops/#{shop.slug}/system/notification_settings/#{boss.id}",
            params: { notification_receive_setting: { invalid_key: true } },
            headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
