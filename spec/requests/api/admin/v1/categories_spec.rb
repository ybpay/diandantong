# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Categories', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:category) { create(:category, shop: shop, branch: branch) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/categories' do
    it 'returns categories list' do
      category
      get '/api/admin/v1/categories', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/categories'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/categories/:id' do
    it 'returns category details' do
      get "/api/admin/v1/categories/#{category.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(category.id)
    end

    it 'returns 404 for non-existent category' do
      get '/api/admin/v1/categories/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/categories' do
    it 'creates a new category' do
      expect {
        post '/api/admin/v1/categories', params: {
          branch_id: branch.id,
          category: { name: '新分类' }
        }, headers: auth_headers
      }.to change { Ddt::Category.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新分类')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/categories', params: { category: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/categories', params: { category: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/categories/:id' do
    it 'updates category name' do
      patch "/api/admin/v1/categories/#{category.id}", params: { category: { name: '更新分类' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新分类')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/categories/#{category.id}", params: { category: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/admin/v1/categories/:id' do
    it 'deletes the category' do
      category
      expect {
        delete "/api/admin/v1/categories/#{category.id}", headers: auth_headers
      }.to change { Ddt::Category.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('分类已删除')
    end
  end
end
