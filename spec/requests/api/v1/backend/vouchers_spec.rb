# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend Vouchers', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:user) { create(:user, shop: shop) }
  let(:voucher_version) { create(:voucher_version, shop: shop) }
  let(:voucher) { create(:voucher, shop: shop, base_user: user, voucher_version: voucher_version) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/marketing/vouchers' do
    it 'returns vouchers list' do
      get "/api/v1/backend/shops/#{shop.slug}/marketing/vouchers", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/marketing/vouchers"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/marketing/vouchers/:id' do
    it 'returns voucher details' do
      get "/api/v1/backend/shops/#{shop.slug}/marketing/vouchers/#{voucher.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(voucher.id)
    end

    it 'returns 404 for non-existent voucher' do
      get "/api/v1/backend/shops/#{shop.slug}/marketing/vouchers/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/marketing/vouchers/:id/refund' do
    it 'refunds a voucher' do
      allow_any_instance_of(Ddt::Voucher).to receive(:refund_coupon).and_return(true)
      post "/api/v1/backend/shops/#{shop.slug}/marketing/vouchers/#{voucher.id}/refund", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('代金券已退款')
    end

    it 'returns 422 when refund fails' do
      allow_any_instance_of(Ddt::Voucher).to receive(:refund_coupon).and_return(false)
      post "/api/v1/backend/shops/#{shop.slug}/marketing/vouchers/#{voucher.id}/refund", headers: auth_headers
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
