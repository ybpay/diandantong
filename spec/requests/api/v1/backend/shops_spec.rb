# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend Shops', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug' do
    it 'returns shop details' do
      get "/api/v1/backend/shops/#{shop.slug}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(shop.id)
      expect(json['data']['name']).to eq(shop.name)
      expect(json['data']['slug']).to eq(shop.slug)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug' do
    it 'updates shop name' do
      patch "/api/v1/backend/shops/#{shop.slug}", params: { shop: { name: '新名称' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新名称')
    end

    it 'returns errors for invalid params' do
      patch "/api/v1/backend/shops/#{shop.slug}", params: { shop: { telephone: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/feature_modules' do
    it 'returns feature modules' do
      get "/api/v1/backend/shops/#{shop.slug}/feature_modules", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches_summary' do
    it 'returns branches summary' do
      get "/api/v1/backend/shops/#{shop.slug}/branches_summary", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']).to have_key('total')
      expect(json['data']).to have_key('active')
      expect(json['data']).to have_key('branches')
    end
  end
end
