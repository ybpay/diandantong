# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend Statistics', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/statistics/business' do
    it 'returns business statistics' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/statistics/business", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']).to have_key('total_orders')
      expect(json['data']).to have_key('total_revenue')
      expect(json['data']).to have_key('avg_order_amount')
      expect(json['data']).to have_key('time_range')
    end

    it 'accepts time range params' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/statistics/business",
          params: { start_time: '2026-01-01', end_time: '2026-12-31' }, headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/statistics/business"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/statistics/orders' do
    it 'returns order statistics' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/statistics/orders", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/statistics/products' do
    it 'returns product statistics' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/statistics/products", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']).to have_key('top_products')
      expect(json['data']).to have_key('time_range')
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/statistics/finance' do
    it 'returns finance statistics' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/statistics/finance", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']).to have_key('total_amount')
      expect(json['data']).to have_key('by_method')
      expect(json['data']).to have_key('time_range')
    end
  end
end
