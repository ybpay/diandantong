# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Inner Shops', type: :request do
  let(:shop) { create(:shop_with_boss) }

  # Inner API uses ApiAuth HMAC-based authentication.
  # We stub the authentication to allow requests in test env.
  before do
    allow(ApiAuth).to receive(:authentic?).and_return(true)
    allow(ApiAuth).to receive(:access_id).and_return('test_api_key')
    allow(Ddt::ApiKey).to receive(:find_by_id).with('test_api_key').and_return(
      Ddt::ApiKey.new(name: 'test', access_token: 'test_secret')
    )
  end

  describe 'GET /api/v1/inner/shops' do
    it 'returns a successful response' do
      get '/api/v1/inner/shops'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns shops as an array' do
      get '/api/v1/inner/shops'
      json = JSON.parse(response.body)
      expect(json['data']).to be_an(Array)
    end

    it 'supports ransack filtering' do
      get '/api/v1/inner/shops', params: { q: { name_cont: shop.name } }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']).to be_an(Array)
    end
  end

  describe 'GET /api/v1/inner/shops/:id' do
    it 'returns the shop details' do
      get "/api/v1/inner/shops/#{shop.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(shop.id)
    end

    it 'returns 404 for a non-existent shop' do
      get '/api/v1/inner/shops/999999'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'authentication requirement' do
    before do
      allow(ApiAuth).to receive(:authentic?).and_return(false)
    end

    it 'returns 401 without valid API key' do
      get '/api/v1/inner/shops'
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
