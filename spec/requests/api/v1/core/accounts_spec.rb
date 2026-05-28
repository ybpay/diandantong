# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Core Accounts', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/accounts' do
    it 'returns the current account' do
      get '/api/v1/accounts', headers: auth_headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']['id']).to eq(boss.id)
      expect(json['data']['login_id']).to eq(boss.login_id)
      expect(json['data']['email']).to eq(boss.email)
      expect(json['data']['name']).to eq(boss.name)
    end

    it 'returns 401 without auth' do
      get '/api/v1/accounts'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/v1/accounts' do
    it 'updates the account name' do
      patch '/api/v1/accounts', params: { account: { name: '新名称' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新名称')
    end

    it 'updates the account email' do
      patch '/api/v1/accounts', params: { account: { email: 'new@example.com' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['data']['email']).to eq('new@example.com')
    end

    it 'returns 422 for invalid params' do
      patch '/api/v1/accounts', params: { account: { email: 'not-an-email' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)

      json = JSON.parse(response.body)
      expect(json).to have_key('errors')
    end

    it 'returns 401 without auth' do
      patch '/api/v1/accounts', params: { account: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
