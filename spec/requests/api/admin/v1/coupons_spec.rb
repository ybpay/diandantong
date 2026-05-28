# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Coupons', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:coupon_version) { create(:coupon_version, shop: shop) }
  let(:user) { create(:user, shop: shop) }
  let(:coupon) { create(:coupon, shop: shop, base_user: user, coupon_version: coupon_version) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/coupons' do
    it 'returns coupons list' do
      coupon
      get '/api/admin/v1/coupons', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/coupons'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/coupons/:id' do
    it 'returns coupon details' do
      get "/api/admin/v1/coupons/#{coupon.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(coupon.id)
    end

    it 'returns 404 for non-existent coupon' do
      get '/api/admin/v1/coupons/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/coupons' do
    it 'creates a new coupon' do
      expect {
        post '/api/admin/v1/coupons', params: {
          coupon: { name: '新优惠券', coupon_type: 'fixed', value: 10.0, min_order_amount: 50.0 }
        }, headers: auth_headers
      }.to change { Ddt::Coupon.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新优惠券')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/coupons', params: { coupon: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/coupons', params: { coupon: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/coupons/:id' do
    it 'updates coupon name' do
      patch "/api/admin/v1/coupons/#{coupon.id}", params: { coupon: { name: '更新优惠券' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新优惠券')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/coupons/#{coupon.id}", params: { coupon: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/admin/v1/coupons/:id' do
    it 'deletes the coupon' do
      coupon
      expect {
        delete "/api/admin/v1/coupons/#{coupon.id}", headers: auth_headers
      }.to change { Ddt::Coupon.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('优惠券已删除')
    end
  end
end
