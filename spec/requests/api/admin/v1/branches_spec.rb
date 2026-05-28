# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Branches', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { create(:branch, shop: shop) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/branches' do
    it 'returns branches list' do
      branch
      get '/api/admin/v1/branches', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/branches'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/branches/:id' do
    it 'returns branch details' do
      get "/api/admin/v1/branches/#{branch.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(branch.id)
    end

    it 'returns 404 for non-existent branch' do
      get '/api/admin/v1/branches/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/branches' do
    it 'creates a new branch' do
      expect {
        post '/api/admin/v1/branches', params: { branch: { name: '新门店', address: '上海市' } }, headers: auth_headers
      }.to change { shop.branches.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新门店')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/branches', params: { branch: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/branches', params: { branch: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/branches/:id' do
    it 'updates branch name' do
      patch "/api/admin/v1/branches/#{branch.id}", params: { branch: { name: '更新门店' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新门店')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/branches/#{branch.id}", params: { branch: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
