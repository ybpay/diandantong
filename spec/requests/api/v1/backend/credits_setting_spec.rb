# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend CreditsSetting', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/crm/credits_setting' do
    before { Ddt::CreditsSetting.find_or_create_by!(shop: shop, exchange_radio: 10) }

    it 'returns credits setting' do
      get "/api/v1/backend/shops/#{shop.slug}/crm/credits_setting", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/crm/credits_setting"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/crm/credits_setting' do
    before { Ddt::CreditsSetting.find_or_create_by!(shop: shop, exchange_radio: 10) }

    it 'updates credits setting' do
      patch "/api/v1/backend/shops/#{shop.slug}/crm/credits_setting",
            params: { credits_setting: { exchange_radio: 10 } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['exchange_radio']).to eq(10)
    end

    it 'returns 422 with invalid params' do
      patch "/api/v1/backend/shops/#{shop.slug}/crm/credits_setting",
            params: { credits_setting: { exchange_radio: -1 } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
