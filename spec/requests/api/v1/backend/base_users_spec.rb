# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend Users', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/user/base_users' do
    it 'returns users list' do
      get "/api/v1/backend/shops/#{shop.slug}/user/base_users", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/user/base_users/normal_users' do
    it 'returns normal users list' do
      get "/api/v1/backend/shops/#{shop.slug}/user/base_users/normal_users", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/user/base_users/vip_users' do
    it 'returns vip users list' do
      get "/api/v1/backend/shops/#{shop.slug}/user/base_users/vip_users", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/user/base_users/:id' do
    let(:user) { create(:user, shop: shop) }

    it 'returns user details' do
      get "/api/v1/backend/shops/#{shop.slug}/user/base_users/#{user.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(user.id)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/user/base_users/:id' do
    let(:user) { create(:user, shop: shop) }

    it 'updates user' do
      patch "/api/v1/backend/shops/#{shop.slug}/user/base_users/#{user.id}",
            params: { base_user: { name: '更新名称' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end
end
