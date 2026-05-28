# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Statistics', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/statistics/business' do
    it 'returns business statistics' do
      get '/api/admin/v1/statistics/business', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to have_key('total_orders')
      expect(json['data']).to have_key('total_revenue')
      expect(json['data']).to have_key('time_range')
    end

    it 'accepts date range params' do
      get '/api/admin/v1/statistics/business', params: {
        start_date: '2026-01-01', end_date: '2026-12-31'
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['time_range']['start']).to be_present
      expect(json['data']['time_range']['end']).to be_present
    end

    it 'accepts branch_id param' do
      get "/api/admin/v1/statistics/business?branch_id=#{branch.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/statistics/business'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/statistics/orders' do
    it 'returns order statistics' do
      get '/api/admin/v1/statistics/orders', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns pagination headers' do
      get '/api/admin/v1/statistics/orders', headers: auth_headers
      expect(response.headers['X-Total-Count']).to be_present
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/statistics/orders'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/statistics/products' do
    it 'returns product statistics' do
      get '/api/admin/v1/statistics/products', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to have_key('top_products')
      expect(json['data']).to have_key('time_range')
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/statistics/products'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/statistics/finance' do
    it 'returns finance statistics' do
      get '/api/admin/v1/statistics/finance', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to have_key('total_amount')
      expect(json['data']).to have_key('by_method')
      expect(json['data']).to have_key('time_range')
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/statistics/finance'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/statistics/coupons' do
    it 'returns coupon statistics' do
      get '/api/admin/v1/statistics/coupons', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to have_key('total_coupons')
      expect(json['data']).to have_key('time_range')
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/statistics/coupons'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/statistics/workers' do
    it 'returns worker statistics' do
      get '/api/admin/v1/statistics/workers', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to have_key('total_served')
      expect(json['data']).to have_key('by_worker')
      expect(json['data']).to have_key('time_range')
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/statistics/workers'
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
