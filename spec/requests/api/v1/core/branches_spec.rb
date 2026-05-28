# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Core Branches', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/shops/:shop_id/branches' do
    it 'returns a list of branches for the shop' do
      get "/api/v1/shops/#{shop.id}/branches", headers: auth_headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'includes pagination headers' do
      get "/api/v1/shops/#{shop.id}/branches", headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(response.headers['X-Total-Count']).to be_present
      expect(response.headers['X-Total-Pages']).to be_present
    end

    it 'returns 401 without auth' do
      get "/api/v1/shops/#{shop.id}/branches"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/shops/:shop_id/branches/:id' do
    it 'returns the branch details' do
      get "/api/v1/shops/#{shop.id}/branches/#{branch.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']['id']).to eq(branch.id)
      expect(json['data']['name']).to eq(branch.name)
    end

    it 'returns 404 for a non-existent branch' do
      get "/api/v1/shops/#{shop.id}/branches/99999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 401 without auth' do
      get "/api/v1/shops/#{shop.id}/branches/#{branch.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/v1/shops/:shop_id/branches/:id' do
    it 'updates the branch name' do
      patch "/api/v1/shops/#{shop.id}/branches/#{branch.id}", params: { branch: { name: '新门店名' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新门店名')
    end

    it 'updates the branch phone' do
      patch "/api/v1/shops/#{shop.id}/branches/#{branch.id}", params: { branch: { phone: '021-12345678' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['data']['phone']).to eq('021-12345678')
    end

    it 'returns 422 for invalid params' do
      patch "/api/v1/shops/#{shop.id}/branches/#{branch.id}", params: { branch: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)

      json = JSON.parse(response.body)
      expect(json).to have_key('errors')
    end

    it 'returns 404 for a non-existent branch' do
      patch "/api/v1/shops/#{shop.id}/branches/99999999", params: { branch: { name: 'test' } }, headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 401 without auth' do
      patch "/api/v1/shops/#{shop.id}/branches/#{branch.id}", params: { branch: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
