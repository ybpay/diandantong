# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Roles', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let!(:role) { Ddt::Role::Custom.create!(shop: shop, name: 'custom_role', display_name: '自定义角色') }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/roles' do
    it 'returns roles list' do
      get '/api/admin/v1/roles', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/roles'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/roles/:id' do
    it 'returns role details' do
      get "/api/admin/v1/roles/#{role.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(role.id)
    end

    it 'returns 404 for non-existent role' do
      get '/api/admin/v1/roles/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/roles' do
    it 'creates a new custom role' do
      expect {
        post '/api/admin/v1/roles', params: {
          role: { display_name: '收银员', description: '负责收银' }
        }, headers: auth_headers
      }.to change { Ddt::Role::Custom.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['display_name']).to eq('收银员')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/roles', params: { role: { display_name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/roles', params: { role: { display_name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/roles/:id' do
    it 'updates custom role display name' do
      patch "/api/admin/v1/roles/#{role.id}", params: {
        role: { display_name: '更新角色' }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['display_name']).to eq('更新角色')
    end

    it 'returns 403 when updating builtin role' do
      builtin_role = shop.roles.builtin.first
      patch "/api/admin/v1/roles/#{builtin_role.id}", params: {
        role: { display_name: '尝试修改' }
      }, headers: auth_headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'DELETE /api/admin/v1/roles/:id' do
    it 'deletes a custom role' do
      expect {
        delete "/api/admin/v1/roles/#{role.id}", headers: auth_headers
      }.to change { Ddt::Role::Custom.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('角色已删除')
    end

    it 'returns 403 when deleting builtin role' do
      builtin_role = shop.roles.builtin.first
      delete "/api/admin/v1/roles/#{builtin_role.id}", headers: auth_headers
      expect(response).to have_http_status(:forbidden)
    end
  end
end
