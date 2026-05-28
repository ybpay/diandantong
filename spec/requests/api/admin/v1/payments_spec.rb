# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Payments', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:payment) { create(:payment, shop: shop) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/payments' do
    it 'returns payments list' do
      payment
      get '/api/admin/v1/payments', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns pagination headers' do
      payment
      get '/api/admin/v1/payments', headers: auth_headers
      expect(response.headers['X-Total-Count']).to be_present
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/payments'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/payments/:id' do
    it 'returns payment details' do
      get "/api/admin/v1/payments/#{payment.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(payment.id)
    end

    it 'returns 404 for non-existent payment' do
      get '/api/admin/v1/payments/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
