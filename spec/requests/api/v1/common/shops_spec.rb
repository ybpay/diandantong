# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Common Shops', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let!(:product) { create(:product, shop: shop, branch: branch) }
  let!(:category) { create(:category, shop: shop, branch: branch) }
  let!(:table) { create(:table, shop: shop, branch: branch, table_zone: create(:table_zone, shop: shop, branch: branch)) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  # --- Shop show ---

  describe 'GET /api/v1/common/shops/:shop_slug' do
    it 'returns shop details with auth' do
      get "/api/v1/common/shops/#{shop.slug}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['slug']).to eq(shop.slug)
    end

    it 'returns 401 without auth' do
      get "/api/v1/common/shops/#{shop.slug}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # --- Products under branch ---

  describe 'GET /api/v1/common/shops/:shop_slug/branches/:branch_id/products' do
    it 'returns products list with auth' do
      get "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/products", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/products"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/common/shops/:shop_slug/branches/:branch_id/products/:id' do
    it 'returns product details with auth' do
      get "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/products/#{product.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(product.id)
    end

    it 'returns 401 without auth' do
      get "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/products/#{product.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # --- Categories under branch ---

  describe 'GET /api/v1/common/shops/:shop_slug/branches/:branch_id/categories' do
    it 'returns categories list with auth' do
      get "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/categories", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/categories"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # --- Orders under branch ---

  describe 'GET /api/v1/common/shops/:shop_slug/branches/:branch_id/orders' do
    it 'returns orders list with auth' do
      get "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/orders", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/orders"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v1/common/shops/:shop_slug/branches/:branch_id/orders' do
    it 'returns 401 without auth' do
      post "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/orders",
           params: { order: { type: 'fastfood' } }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'creates an order with auth' do
      post "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/orders",
           params: { order: { type: 'fastfood' } },
           headers: auth_headers, as: :json
      expect(response).to have_http_status(:created).or have_http_status(:ok)
    end
  end

  # --- Printers under branch ---

  describe 'GET /api/v1/common/shops/:shop_slug/branches/:branch_id/printers' do
    it 'returns printers list with auth' do
      get "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/printers", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/printers"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # --- Tables under branch ---

  describe 'GET /api/v1/common/shops/:shop_slug/branches/:branch_id/tables' do
    it 'returns tables list with auth' do
      get "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/tables", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/common/shops/#{shop.slug}/branches/#{branch.id}/tables"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
