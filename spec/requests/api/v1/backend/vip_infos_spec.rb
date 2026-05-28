# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend VipInfos', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:user) { create(:user, shop: shop) }
  let(:vip_info) { create(:vip_info, shop: shop, user: user) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/crm/vip_infos' do
    it 'returns vip infos list' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/crm/vip_infos", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/crm/vip_infos"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/crm/vip_infos/:id' do
    it 'returns vip info details' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/crm/vip_infos/#{vip_info.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(vip_info.id)
    end

    it 'returns 404 for non-existent vip info' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/crm/vip_infos/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/branches/:branch_id/crm/vip_infos' do
    let(:valid_params) do
      {
        vip_info: {
          name: '张三',
          phone: '13900001234',
          note: '测试会员'
        }
      }
    end

    it 'creates a vip info' do
      post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/crm/vip_infos",
           params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('张三')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/crm/vip_infos",
           params: { vip_info: { phone: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/branches/:branch_id/crm/vip_infos/:id' do
    it 'updates a vip info' do
      patch "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/crm/vip_infos/#{vip_info.id}",
            params: { vip_info: { name: '李四' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('李四')
    end
  end
end
