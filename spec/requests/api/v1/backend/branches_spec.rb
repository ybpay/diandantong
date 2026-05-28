# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend Branches', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches' do
    it 'returns branches list' do
      get "/api/v1/backend/shops/#{shop.slug}/branches", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/branches"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:id' do
    it 'returns branch details' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(branch.id)
    end

    it 'returns 404 for non-existent branch' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/branches' do
    let(:valid_params) do
      {
        branch: {
          name: '新门店',
          phone: '13900001111',
          address: '上海市浦东新区',
          contact_name: '张经理'
        }
      }
    end

    it 'creates a branch' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/branches", params: valid_params, headers: auth_headers
      }.to change { shop.branches.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新门店')
    end

    it 'returns 401 without auth' do
      post "/api/v1/backend/shops/#{shop.slug}/branches", params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/branches",
           params: { branch: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/branches/:id' do
    it 'updates a branch' do
      patch "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}",
            params: { branch: { name: '更新门店' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新门店')
    end

    it 'returns 422 with invalid params' do
      patch "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}",
            params: { branch: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
