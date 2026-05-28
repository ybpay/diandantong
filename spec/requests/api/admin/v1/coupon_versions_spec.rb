# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 CouponVersions', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:coupon_version) { create(:coupon_version, shop: shop) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/coupon_versions' do
    it 'returns coupon versions list' do
      coupon_version
      get '/api/admin/v1/coupon_versions', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/coupon_versions'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/coupon_versions/:id' do
    it 'returns coupon version details' do
      get "/api/admin/v1/coupon_versions/#{coupon_version.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(coupon_version.id)
    end

    it 'returns 404 for non-existent coupon version' do
      get '/api/admin/v1/coupon_versions/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/coupon_versions' do
    it 'creates a new coupon version' do
      expect {
        post '/api/admin/v1/coupon_versions', params: {
          coupon_version: { name: '新活动', coupon_type: 'fixed', norminal_value: 10.0 }
        }, headers: auth_headers
      }.to change { Ddt::CouponVersion.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新活动')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/coupon_versions', params: { coupon_version: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/coupon_versions', params: { coupon_version: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/coupon_versions/:id' do
    it 'updates coupon version name' do
      patch "/api/admin/v1/coupon_versions/#{coupon_version.id}", params: {
        coupon_version: { name: '更新活动' }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新活动')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/coupon_versions/#{coupon_version.id}", params: {
        coupon_version: { name: '' }
      }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/admin/v1/coupon_versions/:id' do
    it 'deletes the coupon version' do
      coupon_version
      expect {
        delete "/api/admin/v1/coupon_versions/#{coupon_version.id}", headers: auth_headers
      }.to change { Ddt::CouponVersion.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('优惠券版本已删除')
    end
  end
end
