# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 VipLevels', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:vip_level) { create(:vip_level, shop: shop) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/vip_levels' do
    it 'returns vip levels list' do
      vip_level
      get '/api/admin/v1/vip_levels', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/vip_levels'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/vip_levels/:id' do
    it 'returns vip level details' do
      get "/api/admin/v1/vip_levels/#{vip_level.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(vip_level.id)
    end

    it 'returns 404 for non-existent vip level' do
      get '/api/admin/v1/vip_levels/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/vip_levels' do
    it 'creates a new vip level' do
      expect {
        post '/api/admin/v1/vip_levels', params: {
          vip_level: { name: '金卡会员', discount: 0.9, level: 2 }
        }, headers: auth_headers
      }.to change { Ddt::VipLevel.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('金卡会员')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/vip_levels', params: { vip_level: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/vip_levels', params: { vip_level: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/vip_levels/:id' do
    it 'updates vip level name' do
      patch "/api/admin/v1/vip_levels/#{vip_level.id}", params: {
        vip_level: { name: '更新等级' }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新等级')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/vip_levels/#{vip_level.id}", params: {
        vip_level: { name: '' }
      }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/admin/v1/vip_levels/:id' do
    it 'deletes the vip level' do
      vip_level
      expect {
        delete "/api/admin/v1/vip_levels/#{vip_level.id}", headers: auth_headers
      }.to change { Ddt::VipLevel.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('VIP等级已删除')
    end
  end
end
