# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Core Auth', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  describe 'POST /api/v1/auth/login' do
    let(:login_params) do
      { login_id: boss.login_id, password: 'password123' }
    end

    it 'returns account data with authentication_token on valid credentials' do
      post '/api/v1/auth/login', params: login_params, headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']['login_id']).to eq(boss.login_id)
      expect(json['data']['email']).to eq(boss.email)
      expect(json['data']['name']).to eq(boss.name)
      expect(json['data']['authentication_token']).to be_present
      expect(json['data']['is_admin']).to eq(false)
      expect(json['data']['shop_id']).to eq(shop.id)
      expect(json['data']['shop_name']).to eq(shop.name)
    end

    it 'returns 401 with wrong password' do
      post '/api/v1/auth/login', params: { login_id: boss.login_id, password: 'wrong_password' }, headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)

      json = JSON.parse(response.body)
      expect(json).to have_key('errors')
      expect(json['errors'].first['code']).to eq('AUTH_FAILED')
    end

    it 'returns 401 with non-existent login_id' do
      post '/api/v1/auth/login', params: { login_id: 'nonexistent', password: 'password123' }, headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)

      json = JSON.parse(response.body)
      expect(json['errors'].first['code']).to eq('AUTH_FAILED')
    end

    it 'allows login via email address' do
      post '/api/v1/auth/login', params: { login_id: boss.email, password: 'password123' }, headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['data']['login_id']).to eq(boss.login_id)
    end

    it 'does not require authentication' do
      post '/api/v1/auth/login', params: login_params, headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /api/v1/auth/me' do
    let(:auth_headers) do
      { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
    end

    it 'returns current account data' do
      get '/api/v1/auth/me', headers: auth_headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']['id']).to eq(boss.id)
      expect(json['data']['login_id']).to eq(boss.login_id)
      expect(json['data']['email']).to eq(boss.email)
      expect(json['data']['name']).to eq(boss.name)
      expect(json['data']['phone']).to eq(boss.phone)
      expect(json['data']['is_admin']).to eq(false)
      expect(json['data']['shop_id']).to eq(shop.id)
      expect(json['data']['shop_name']).to eq(shop.name)
      expect(json['data']['role']).to be_present
    end

    it 'returns 401 without auth' do
      get '/api/v1/auth/me'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 with invalid token' do
      get '/api/v1/auth/me', headers: { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => 'invalid_token' }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
