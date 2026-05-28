# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend Orders', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/orders' do
    it 'returns orders list' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/orders", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/branches/:branch_id/orders/batch_change_state' do
    it 'returns error without order_ids' do
      post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/orders/batch_change_state",
           params: { state_action: 'confirm' }, headers: auth_headers
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'order type-specific endpoints' do
    describe 'delivery orders' do
      it 'returns delivery orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/delivery_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'eat in hall orders' do
      it 'returns eat in hall orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/eat_in_hall_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'fastfood orders' do
      it 'returns fastfood orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/fastfood_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'groupon orders' do
      it 'returns groupon orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/groupon_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'reservation orders' do
      it 'returns reservation orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/reservation_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'recharge orders' do
      it 'returns recharge orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/recharge_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'payment orders' do
      it 'returns payment orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/payment_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
