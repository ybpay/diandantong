# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Groupons', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:user) { create(:user, shop: shop) }
  let(:groupon_version) { create(:groupon_version, shop: shop) }
  let(:groupon) { create(:groupon, shop: shop, base_user: user, groupon_version: groupon_version) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/groupons' do
    it 'returns groupons list' do
      groupon
      get '/api/admin/v1/groupons', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns pagination headers' do
      groupon
      get '/api/admin/v1/groupons', headers: auth_headers
      expect(response.headers['X-Total-Count']).to be_present
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/groupons'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/groupons/:id' do
    it 'returns groupon details' do
      get "/api/admin/v1/groupons/#{groupon.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(groupon.id)
    end

    it 'returns 404 for non-existent groupon' do
      get '/api/admin/v1/groupons/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/groupons/:id/refund' do
    it 'refunds the groupon' do
      allow_any_instance_of(Ddt::Groupon).to receive(:refund_coupon).and_return(true)
      post "/api/admin/v1/groupons/#{groupon.id}/refund", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('团购券已退款')
    end

    it 'returns error when refund fails' do
      allow_any_instance_of(Ddt::Groupon).to receive(:refund_coupon).and_return(false)
      post "/api/admin/v1/groupons/#{groupon.id}/refund", headers: auth_headers
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'returns error when refund raises exception' do
      allow_any_instance_of(Ddt::Groupon).to receive(:refund_coupon).and_raise(StandardError, '退款异常')
      post "/api/admin/v1/groupons/#{groupon.id}/refund", headers: auth_headers
      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json['errors'].first['detail']).to eq('退款异常')
    end

    it 'returns 401 without auth' do
      post "/api/admin/v1/groupons/#{groupon.id}/refund"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
