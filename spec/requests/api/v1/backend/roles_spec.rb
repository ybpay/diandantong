# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend Roles', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/system/roles' do
    it 'returns roles list' do
      get "/api/v1/backend/shops/#{shop.slug}/system/roles", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/system/roles"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/system/roles/:id' do
    let(:role) { shop.roles.first }

    it 'returns role details' do
      get "/api/v1/backend/shops/#{shop.slug}/system/roles/#{role.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(role.id)
    end

    it 'returns 404 for non-existent role' do
      get "/api/v1/backend/shops/#{shop.slug}/system/roles/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/system/roles' do
    let(:valid_params) do
      {
        role: {
          display_name: '收银员',
          description: '收银台操作权限'
        }
      }
    end

    it 'creates a custom role' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/system/roles", params: valid_params, headers: auth_headers
      }.to change { shop.roles.custom.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['display_name']).to eq('收银员')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/system/roles",
           params: { role: { display_name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/system/roles/:id' do
    let(:role) { Ddt::Role::Custom.create!(shop: shop, name: 'custom', display_name: '收银员', builtin: false) }

    it 'updates a custom role' do
      patch "/api/v1/backend/shops/#{shop.slug}/system/roles/#{role.id}",
            params: { role: { display_name: '高级收银员' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['display_name']).to eq('高级收银员')
    end
  end

  describe 'DELETE /api/v1/backend/shops/:shop_slug/system/roles/:id' do
    let!(:role) { Ddt::Role::Custom.create!(shop: shop, name: 'custom', display_name: '服务员', builtin: false) }

    it 'deletes a custom role' do
      expect {
        delete "/api/v1/backend/shops/#{shop.slug}/system/roles/#{role.id}", headers: auth_headers
      }.to change { shop.roles.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('角色已删除')
    end
  end
end
