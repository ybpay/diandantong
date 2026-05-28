# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend Coupons', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/coupons' do
    it 'returns coupons list' do
      get "/api/v1/backend/shops/#{shop.slug}/coupons", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/coupons"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/coupons/:id' do
    let(:coupon_version) { create(:coupon_version, shop: shop) }
    let(:user) { create(:user, shop: shop) }
    let(:coupon) { create(:coupon, shop: shop, base_user: user, coupon_version: coupon_version) }

    it 'returns coupon details' do
      get "/api/v1/backend/shops/#{shop.slug}/coupons/#{coupon.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(coupon.id)
    end

    it 'returns 404 for non-existent coupon' do
      get "/api/v1/backend/shops/#{shop.slug}/coupons/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/coupons' do
    let(:valid_params) do
      {
        coupon: {
          name: '满减券',
          coupon_type: 'cash',
          value: 10.0,
          min_order_amount: 50.0,
          total_count: 100
        }
      }
    end

    it 'creates a coupon' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/coupons", params: valid_params, headers: auth_headers
      }.to change { shop.coupons.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('满减券')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/coupons",
           params: { coupon: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/coupons/:id' do
    let(:coupon_version) { create(:coupon_version, shop: shop) }
    let(:user) { create(:user, shop: shop) }
    let(:coupon) { create(:coupon, shop: shop, base_user: user, coupon_version: coupon_version) }

    it 'updates a coupon' do
      patch "/api/v1/backend/shops/#{shop.slug}/coupons/#{coupon.id}",
            params: { coupon: { name: '更新优惠券' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新优惠券')
    end
  end

  describe 'DELETE /api/v1/backend/shops/:shop_slug/coupons/:id' do
    let(:coupon_version) { create(:coupon_version, shop: shop) }
    let(:user) { create(:user, shop: shop) }
    let!(:coupon) { create(:coupon, shop: shop, base_user: user, coupon_version: coupon_version) }

    it 'deletes a coupon' do
      expect {
        delete "/api/v1/backend/shops/#{shop.slug}/coupons/#{coupon.id}", headers: auth_headers
      }.to change { shop.coupons.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('优惠券已删除')
    end
  end
end
