# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend VipLevels', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/crm/vip_levels' do
    it 'returns vip levels list' do
      get "/api/v1/backend/shops/#{shop.slug}/crm/vip_levels", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/crm/vip_levels"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/crm/vip_levels/:id' do
    let(:vip_level) { create(:vip_level, shop: shop) }

    it 'returns vip level details' do
      get "/api/v1/backend/shops/#{shop.slug}/crm/vip_levels/#{vip_level.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(vip_level.id)
    end

    it 'returns 404 for non-existent vip level' do
      get "/api/v1/backend/shops/#{shop.slug}/crm/vip_levels/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/crm/vip_levels' do
    let(:valid_params) do
      {
        vip_level: {
          name: '银卡会员',
          level: 2,
          discount: 0.9,
          auto_upgrade: true,
          upgrade_total_amount: 1000
        }
      }
    end

    it 'creates a vip level' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/crm/vip_levels", params: valid_params, headers: auth_headers
      }.to change { shop.vip_levels.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('银卡会员')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/crm/vip_levels",
           params: { vip_level: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/crm/vip_levels/:id' do
    let(:vip_level) { create(:vip_level, shop: shop) }

    it 'updates a vip level' do
      patch "/api/v1/backend/shops/#{shop.slug}/crm/vip_levels/#{vip_level.id}",
            params: { vip_level: { name: '更新等级' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新等级')
    end
  end

  describe 'DELETE /api/v1/backend/shops/:shop_slug/crm/vip_levels/:id' do
    let!(:vip_level) { create(:vip_level, shop: shop) }

    it 'deletes a vip level' do
      expect {
        delete "/api/v1/backend/shops/#{shop.slug}/crm/vip_levels/#{vip_level.id}", headers: auth_headers
      }.to change { shop.vip_levels.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('VIP等级已删除')
    end
  end
end
