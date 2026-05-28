# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Weixin Branch Resources', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let!(:product) { create(:product, shop: shop, branch: branch) }
  let!(:category) { create(:category, shop: shop, branch: branch) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  # --- Products ---

  describe 'GET /api/v1/weixin/shops/:shop_id/branches/:branch_id/products' do
    it 'returns a successful response' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/products"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns products as an array' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/products"
      json = JSON.parse(response.body)
      expect(json['data']).to be_an(Array)
    end

    it 'includes pagination headers' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/products"
      expect(response.headers['X-Total-Count']).to be_present
    end
  end

  describe 'GET /api/v1/weixin/shops/:shop_id/branches/:branch_id/products/:id' do
    it 'returns the product details' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/products/#{product.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(product.id)
    end

    it 'returns 404 for a non-existent product' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/products/999999"
      expect(response).to have_http_status(:not_found)
    end
  end

  # --- Categories ---

  describe 'GET /api/v1/weixin/shops/:shop_id/branches/:branch_id/categories' do
    it 'returns a successful response' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/categories"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns categories as an array' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/categories"
      json = JSON.parse(response.body)
      expect(json['data']).to be_an(Array)
    end
  end

  # --- Orders ---

  describe 'GET /api/v1/weixin/shops/:shop_id/branches/:branch_id/orders' do
    it 'returns 401 without auth' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/orders"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns orders list with auth' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/orders", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end
  end

  describe 'POST /api/v1/weixin/shops/:shop_id/branches/:branch_id/orders' do
    it 'returns 401 without auth' do
      post "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/orders", params: { order: { type: 'fastfood' } }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'creates an order with auth' do
      post "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/orders",
           params: { order: { type: 'fastfood' } },
           headers: auth_headers
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']).to have_key('id')
    end

    it 'returns errors for invalid params' do
      post "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/orders",
           params: { order: {} },
           headers: auth_headers
      expect(response).to have_http_status(:bad_request).or have_http_status(:unprocessable_entity)
    end
  end

  # --- Guest Queues ---

  describe 'GET /api/v1/weixin/shops/:shop_id/branches/:branch_id/guest_queues' do
    it 'returns 401 without auth' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/guest_queues"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns guest queues list with auth' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/guest_queues", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end
  end

  describe 'POST /api/v1/weixin/shops/:shop_id/branches/:branch_id/guest_queues' do
    let(:queue_setting) { create(:queue_setting, shop: shop, branch: branch) }

    it 'returns 401 without auth' do
      post "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/guest_queues",
           params: { guest_queue: { person_count: 2 } }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'creates a guest queue with auth' do
      post "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/guest_queues",
           params: { guest_queue: { person_count: 2, phone: '13900000001' } },
           headers: auth_headers
      expect(response).to have_http_status(:created).or have_http_status(:ok)
    end
  end

  describe 'GET /api/v1/weixin/shops/:shop_id/branches/:branch_id/guest_queues/:id' do
    let(:queue_setting) { create(:queue_setting, shop: shop, branch: branch) }
    let!(:guest_queue) { create(:guest_queue, shop: shop, branch: branch, queue_setting: queue_setting) }

    it 'returns 401 without auth' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/guest_queues/#{guest_queue.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns guest queue details with auth' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/guest_queues/#{guest_queue.id}",
          headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(guest_queue.id)
    end
  end

  # --- VIP Infos ---

  describe 'GET /api/v1/weixin/shops/:shop_id/branches/:branch_id/vip_infos' do
    it 'returns 401 without auth' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/vip_infos"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns vip infos list with auth' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/vip_infos", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end
  end

  describe 'GET /api/v1/weixin/shops/:shop_id/branches/:branch_id/vip_infos/:id' do
    let(:user) { create(:user, shop: shop) }
    let!(:vip_info) { create(:vip_info, shop: shop, user: user) }

    it 'returns 401 without auth' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/vip_infos/#{vip_info.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns vip info details with auth' do
      get "/api/v1/weixin/shops/#{shop.id}/branches/#{branch.id}/vip_infos/#{vip_info.id}",
          headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(vip_info.id)
    end
  end
end
