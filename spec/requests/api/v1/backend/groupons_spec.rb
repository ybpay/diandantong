# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend Groupons', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:user) { create(:user, shop: shop) }
  let(:groupon_version) { create(:groupon_version, shop: shop) }
  let(:groupon) { create(:groupon, shop: shop, base_user: user, groupon_version: groupon_version) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/marketing/groupons' do
    it 'returns groupons list' do
      get "/api/v1/backend/shops/#{shop.slug}/marketing/groupons", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/marketing/groupons"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/marketing/groupons/:id' do
    it 'returns groupon details' do
      get "/api/v1/backend/shops/#{shop.slug}/marketing/groupons/#{groupon.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(groupon.id)
    end

    it 'returns 404 for non-existent groupon' do
      get "/api/v1/backend/shops/#{shop.slug}/marketing/groupons/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/marketing/groupons/:id/refund' do
    it 'refunds a groupon' do
      allow_any_instance_of(Ddt::Groupon).to receive(:refund_coupon).and_return(true)
      post "/api/v1/backend/shops/#{shop.slug}/marketing/groupons/#{groupon.id}/refund", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('团购券已退款')
    end

    it 'returns 422 when refund fails' do
      allow_any_instance_of(Ddt::Groupon).to receive(:refund_coupon).and_return(false)
      post "/api/v1/backend/shops/#{shop.slug}/marketing/groupons/#{groupon.id}/refund", headers: auth_headers
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
