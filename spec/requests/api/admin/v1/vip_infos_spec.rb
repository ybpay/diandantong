# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 VipInfos', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:user) { create(:user, shop: shop) }
  let(:vip_info) { create(:vip_info, shop: shop, user: user) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/vip_infos' do
    it 'returns vip infos list' do
      vip_info
      get '/api/admin/v1/vip_infos', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/vip_infos'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/vip_infos/:id' do
    it 'returns vip info details' do
      get "/api/admin/v1/vip_infos/#{vip_info.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(vip_info.id)
    end

    it 'returns 404 for non-existent vip info' do
      get '/api/admin/v1/vip_infos/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/vip_infos' do
    it 'creates a new vip info' do
      expect {
        post '/api/admin/v1/vip_infos', params: {
          vip_info: { name: '测试会员', phone: '15000009999' }
        }, headers: auth_headers
      }.to change { Ddt::VipInfo.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('测试会员')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/vip_infos', params: { vip_info: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/vip_infos', params: { vip_info: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/vip_infos/:id' do
    it 'updates vip info name' do
      patch "/api/admin/v1/vip_infos/#{vip_info.id}", params: {
        vip_info: { name: '更新会员' }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新会员')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/vip_infos/#{vip_info.id}", params: {
        vip_info: { name: '' }
      }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
