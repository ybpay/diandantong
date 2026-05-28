# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Orders', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:user) { create(:user, shop: shop) }
  let(:order) { create(:order, shop: shop, branch: branch, user: user) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/orders' do
    it 'returns orders list' do
      order
      get '/api/admin/v1/orders', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns pagination headers' do
      order
      get '/api/admin/v1/orders', headers: auth_headers
      expect(response.headers['X-Total-Count']).to be_present
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/orders'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/orders/:id' do
    it 'returns order details' do
      get "/api/admin/v1/orders/#{order.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(order.id)
    end

    it 'returns 404 for non-existent order' do
      get '/api/admin/v1/orders/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /api/admin/v1/orders/:id' do
    it 'updates order note' do
      patch "/api/admin/v1/orders/#{order.id}", params: { order: { note: '备注信息' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['note']).to eq('备注信息')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/orders/#{order.id}", params: { order: {} }, headers: auth_headers
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns 401 without auth' do
      patch "/api/admin/v1/orders/#{order.id}", params: { order: { note: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
