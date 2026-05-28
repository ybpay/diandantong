# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend CouponVersions', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/marketing/coupon_versions' do
    it 'returns coupon versions list' do
      get "/api/v1/backend/shops/#{shop.slug}/marketing/coupon_versions", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/marketing/coupon_versions"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/marketing/coupon_versions/:id' do
    let(:coupon_version) { create(:coupon_version, shop: shop) }

    it 'returns coupon version details' do
      get "/api/v1/backend/shops/#{shop.slug}/marketing/coupon_versions/#{coupon_version.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(coupon_version.id)
    end

    it 'returns 404 for non-existent coupon version' do
      get "/api/v1/backend/shops/#{shop.slug}/marketing/coupon_versions/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/marketing/coupon_versions' do
    let(:valid_params) do
      {
        coupon_version: {
          name: '新优惠券活动',
          coupon_type: 'cash',
          norminal_value: 15.0,
          coupon_min_usable_amount: 60.0,
          total_count: 200,
          per_user_limit: 1
        }
      }
    end

    it 'creates a coupon version' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/marketing/coupon_versions", params: valid_params, headers: auth_headers
      }.to change { shop.coupon_versions.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新优惠券活动')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/marketing/coupon_versions",
           params: { coupon_version: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/marketing/coupon_versions/:id' do
    let(:coupon_version) { create(:coupon_version, shop: shop) }

    it 'updates a coupon version' do
      patch "/api/v1/backend/shops/#{shop.slug}/marketing/coupon_versions/#{coupon_version.id}",
            params: { coupon_version: { name: '更新活动' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新活动')
    end
  end

  describe 'DELETE /api/v1/backend/shops/:shop_slug/marketing/coupon_versions/:id' do
    let!(:coupon_version) { create(:coupon_version, shop: shop) }

    it 'deletes a coupon version' do
      expect {
        delete "/api/v1/backend/shops/#{shop.slug}/marketing/coupon_versions/#{coupon_version.id}", headers: auth_headers
      }.to change { shop.coupon_versions.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('优惠券版本已删除')
    end
  end
end
