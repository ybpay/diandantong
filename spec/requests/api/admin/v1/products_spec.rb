# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Products', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:product) { create(:product, shop: shop, branch: branch) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/products' do
    it 'returns products list' do
      product
      get '/api/admin/v1/products', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns pagination headers' do
      product
      get '/api/admin/v1/products', headers: auth_headers
      expect(response.headers['X-Total-Count']).to be_present
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/products'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/products/:id' do
    it 'returns product details with variants' do
      get "/api/admin/v1/products/#{product.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(product.id)
    end

    it 'returns 404 for non-existent product' do
      get '/api/admin/v1/products/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/products' do
    it 'creates a new product' do
      expect {
        post '/api/admin/v1/products', params: {
          branch_id: branch.id,
          product: { name: '新菜品', price: 30.0 }
        }, headers: auth_headers
      }.to change { Ddt::Product.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新菜品')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/products', params: { product: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/products', params: { product: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/products/:id' do
    it 'updates product name' do
      patch "/api/admin/v1/products/#{product.id}", params: { product: { name: '更新菜品' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新菜品')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/products/#{product.id}", params: { product: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/admin/v1/products/:id' do
    it 'deletes the product' do
      product
      expect {
        delete "/api/admin/v1/products/#{product.id}", headers: auth_headers
      }.to change { Ddt::Product.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('产品已删除')
    end

    it 'returns 404 for non-existent product' do
      delete '/api/admin/v1/products/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
