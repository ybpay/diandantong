# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Shop', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/shop' do
    it 'returns shop details' do
      get '/api/admin/v1/shop', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']['id']).to eq(shop.id)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/shop'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/shop' do
    it 'updates shop name' do
      patch '/api/admin/v1/shop', params: { shop: { name: '新名称' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新名称')
    end

    it 'returns errors for invalid params' do
      patch '/api/admin/v1/shop', params: { shop: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json).to have_key('errors')
    end

    it 'returns 401 without auth' do
      patch '/api/admin/v1/shop', params: { shop: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
