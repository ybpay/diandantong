# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Accounts', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:account) { create(:account, shop: shop) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/accounts' do
    it 'returns accounts list' do
      account
      get '/api/admin/v1/accounts', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/accounts'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/accounts/:id' do
    it 'returns account details' do
      get "/api/admin/v1/accounts/#{account.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(account.id)
    end

    it 'returns 404 for non-existent account' do
      get '/api/admin/v1/accounts/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/accounts' do
    it 'creates a new account' do
      expect {
        post '/api/admin/v1/accounts', params: {
          account: { name: '新员工', email: 'new@example.com', phone: '13900009999', password: 'password123', password_confirmation: 'password123' }
        }, headers: auth_headers
      }.to change { Ddt::Account.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新员工')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/accounts', params: { account: { name: '', email: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/accounts', params: { account: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/accounts/:id' do
    it 'updates account name' do
      patch "/api/admin/v1/accounts/#{account.id}", params: {
        account: { name: '更新员工' }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新员工')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/accounts/#{account.id}", params: {
        account: { email: 'invalid' }
      }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/admin/v1/accounts/:id' do
    it 'deletes the account' do
      account
      expect {
        delete "/api/admin/v1/accounts/#{account.id}", headers: auth_headers
      }.to change { Ddt::Account.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('账号已删除')
    end
  end
end
