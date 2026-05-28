# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Vouchers', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:user) { create(:user, shop: shop) }
  let(:voucher_version) { create(:voucher_version, shop: shop) }
  let(:voucher) { create(:voucher, shop: shop, base_user: user, voucher_version: voucher_version) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/vouchers' do
    it 'returns vouchers list' do
      voucher
      get '/api/admin/v1/vouchers', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns pagination headers' do
      voucher
      get '/api/admin/v1/vouchers', headers: auth_headers
      expect(response.headers['X-Total-Count']).to be_present
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/vouchers'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/vouchers/:id' do
    it 'returns voucher details' do
      get "/api/admin/v1/vouchers/#{voucher.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(voucher.id)
    end

    it 'returns 404 for non-existent voucher' do
      get '/api/admin/v1/vouchers/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/vouchers/:id/refund' do
    it 'refunds the voucher' do
      allow_any_instance_of(Ddt::Voucher).to receive(:refund_coupon).and_return(true)
      post "/api/admin/v1/vouchers/#{voucher.id}/refund", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('代金券已退款')
    end

    it 'returns error when refund fails' do
      allow_any_instance_of(Ddt::Voucher).to receive(:refund_coupon).and_return(false)
      post "/api/admin/v1/vouchers/#{voucher.id}/refund", headers: auth_headers
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'returns error when refund raises exception' do
      allow_any_instance_of(Ddt::Voucher).to receive(:refund_coupon).and_raise(StandardError, '退款异常')
      post "/api/admin/v1/vouchers/#{voucher.id}/refund", headers: auth_headers
      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json['errors'].first['detail']).to eq('退款异常')
    end

    it 'returns 401 without auth' do
      post "/api/admin/v1/vouchers/#{voucher.id}/refund"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
