# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend Products', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/products' do
    it 'returns products list' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/products", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/products"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/products/search' do
    it 'returns search results' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/products/search",
          params: { q: { name_cont: '测试' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/products/:id' do
    let(:product) { create(:product, shop: shop, branch: branch) }

    it 'returns product details' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/products/#{product.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(product.id)
    end

    it 'returns 404 for non-existent product' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/products/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/branches/:branch_id/products' do
    let(:valid_params) do
      {
        product: {
          name: '新菜品',
          price: 38.0,
          is_available: true
        }
      }
    end

    it 'creates a product' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/products",
             params: valid_params, headers: auth_headers
      }.to change { branch.products.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新菜品')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/products",
           params: { product: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/branches/:branch_id/products/:id' do
    let(:product) { create(:product, shop: shop, branch: branch) }

    it 'updates a product' do
      patch "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/products/#{product.id}",
            params: { product: { name: '更新菜品' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新菜品')
    end
  end

  describe 'DELETE /api/v1/backend/shops/:shop_slug/branches/:branch_id/products/:id' do
    let!(:product) { create(:product, shop: shop, branch: branch) }

    it 'deletes a product' do
      expect {
        delete "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/products/#{product.id}", headers: auth_headers
      }.to change { branch.products.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('产品已删除')
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/branches/:branch_id/products/batch_on_shelf' do
    let!(:product) { create(:product, shop: shop, branch: branch, is_available: false) }

    it 'batch enables products' do
      post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/products/batch_on_shelf",
           params: { product_ids: [product.id] }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('批量上架成功')
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/branches/:branch_id/products/batch_off_shelf' do
    let!(:product) { create(:product, shop: shop, branch: branch, is_available: true) }

    it 'batch disables products' do
      post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/products/batch_off_shelf",
           params: { product_ids: [product.id] }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('批量下架成功')
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/branches/:branch_id/products/batch_remove' do
    let!(:product) { create(:product, shop: shop, branch: branch) }

    it 'batch removes products' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/products/batch_remove",
             params: { product_ids: [product.id] }, headers: auth_headers
      }.to change { branch.products.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('批量删除成功')
    end

    it 'returns 400 without product_ids' do
      post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/products/batch_remove",
           params: {}, headers: auth_headers
      expect(response).to have_http_status(:bad_request)
    end
  end
end
