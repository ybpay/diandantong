# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Weixin Shops', type: :request do
  let(:shop) { create(:shop_with_boss) }

  describe 'GET /api/v1/weixin/shops' do
    it 'returns a successful response' do
      get '/api/v1/weixin/shops'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns shops as an array' do
      get '/api/v1/weixin/shops'
      json = JSON.parse(response.body)
      expect(json['data']).to be_an(Array)
    end

    it 'includes pagination headers' do
      get '/api/v1/weixin/shops'
      expect(response.headers['X-Total-Count']).to be_present
    end

    it 'filters shops by ransack params' do
      get '/api/v1/weixin/shops', params: { q: { name_cont: shop.name } }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']).to be_an(Array)
    end
  end

  describe 'GET /api/v1/weixin/shops/:id' do
    it 'returns the shop details' do
      get "/api/v1/weixin/shops/#{shop.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(shop.id)
    end

    it 'returns 404 for a non-existent shop' do
      get '/api/v1/weixin/shops/999999'
      expect(response).to have_http_status(:not_found)
    end
  end
end
