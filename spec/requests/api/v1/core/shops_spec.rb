# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Core Shops', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/shops' do
    it 'returns a list of shops' do
      get '/api/v1/shops', headers: auth_headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'includes pagination headers' do
      get '/api/v1/shops', headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(response.headers['X-Total-Count']).to be_present
      expect(response.headers['X-Total-Pages']).to be_present
      expect(response.headers['X-Per-Page']).to be_present
      expect(response.headers['X-Page']).to be_present
    end

    it 'returns 401 without auth' do
      get '/api/v1/shops'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/shops/:id' do
    it 'returns the shop details' do
      get "/api/v1/shops/#{shop.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']['id']).to eq(shop.id)
      expect(json['data']['name']).to eq(shop.name)
    end

    it 'returns 404 for a non-existent shop' do
      get '/api/v1/shops/99999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 401 without auth' do
      get "/api/v1/shops/#{shop.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
