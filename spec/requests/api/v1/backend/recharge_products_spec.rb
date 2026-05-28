# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend RechargeProducts', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/crm/recharge_products' do
    it 'returns recharge products list' do
      get "/api/v1/backend/shops/#{shop.slug}/crm/recharge_products", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/crm/recharge_products"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/crm/recharge_products/:id' do
    let(:recharge_product) { Ddt::RechargeProduct.create!(shop: shop, name: '充值100', price: 100, recharge_amount: 120, extra_credits: 10) }

    it 'returns recharge product details' do
      get "/api/v1/backend/shops/#{shop.slug}/crm/recharge_products/#{recharge_product.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(recharge_product.id)
    end

    it 'returns 404 for non-existent recharge product' do
      get "/api/v1/backend/shops/#{shop.slug}/crm/recharge_products/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/crm/recharge_products' do
    let(:valid_params) do
      {
        recharge_product: {
          name: '充值100送20',
          price: 100.0,
          recharge_amount: 120.0,
          extra_credits: 50
        }
      }
    end

    it 'creates a recharge product' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/crm/recharge_products", params: valid_params, headers: auth_headers
      }.to change { shop.recharge_products.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('充值100送20')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/crm/recharge_products",
           params: { recharge_product: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/crm/recharge_products/:id' do
    let(:recharge_product) { Ddt::RechargeProduct.create!(shop: shop, name: '充值100', price: 100, recharge_amount: 120, extra_credits: 10) }

    it 'updates a recharge product' do
      patch "/api/v1/backend/shops/#{shop.slug}/crm/recharge_products/#{recharge_product.id}",
            params: { recharge_product: { name: '更新充值产品' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新充值产品')
    end
  end

  describe 'DELETE /api/v1/backend/shops/:shop_slug/crm/recharge_products/:id' do
    let!(:recharge_product) { Ddt::RechargeProduct.create!(shop: shop, name: '充值100', price: 100, recharge_amount: 120, extra_credits: 10) }

    it 'deletes a recharge product' do
      expect {
        delete "/api/v1/backend/shops/#{shop.slug}/crm/recharge_products/#{recharge_product.id}", headers: auth_headers
      }.to change { shop.recharge_products.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('充值产品已删除')
    end
  end

  describe 'PUT /api/v1/backend/shops/:shop_slug/crm/recharge_products/:id/change_position' do
    let(:recharge_product) { Ddt::RechargeProduct.create!(shop: shop, name: '充值100', price: 100, recharge_amount: 120, extra_credits: 10) }

    it 'changes position of a recharge product' do
      put "/api/v1/backend/shops/#{shop.slug}/crm/recharge_products/#{recharge_product.id}/change_position",
          params: { position: 2 }, headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end
end
