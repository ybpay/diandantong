# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend Payments', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:payment_method) { create(:payment_method, shop: shop) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/payment/payments' do
    it 'returns payments list' do
      get "/api/v1/backend/shops/#{shop.slug}/payment/payments", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns paginated results' do
      get "/api/v1/backend/shops/#{shop.slug}/payment/payments", headers: auth_headers
      expect(response.headers['X-Total-Count']).to be_present
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/payment/payments/:id' do
    let(:payment) { create(:payment, shop: shop, branch: branch, payment_method: payment_method) }

    it 'returns payment details' do
      get "/api/v1/backend/shops/#{shop.slug}/payment/payments/#{payment.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(payment.id)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/payment/payments/statistics' do
    it 'returns payment statistics' do
      get "/api/v1/backend/shops/#{shop.slug}/payment/payments/statistics", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']).to have_key('total_amount')
      expect(json['data']).to have_key('count')
    end
  end
end
