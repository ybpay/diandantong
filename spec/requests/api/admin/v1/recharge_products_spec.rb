# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 RechargeProducts', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:recharge_product) do
    Ddt::RechargeProduct.create!(
      shop: shop, name: '充值100', price: 100, recharge_amount: 120,
      extra_credits: 10, first_recharge_available_amount: 100
    )
  end

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/recharge_products' do
    it 'returns recharge products list' do
      recharge_product
      get '/api/admin/v1/recharge_products', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/recharge_products'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/recharge_products/:id' do
    it 'returns recharge product details' do
      get "/api/admin/v1/recharge_products/#{recharge_product.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(recharge_product.id)
    end

    it 'returns 404 for non-existent recharge product' do
      get '/api/admin/v1/recharge_products/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/recharge_products' do
    it 'creates a new recharge product' do
      expect {
        post '/api/admin/v1/recharge_products', params: {
          recharge_product: { name: '充值200', price: 200, recharge_amount: 240 }
        }, headers: auth_headers
      }.to change { Ddt::RechargeProduct.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('充值200')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/recharge_products', params: { recharge_product: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/recharge_products', params: { recharge_product: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/recharge_products/:id' do
    it 'updates recharge product name' do
      patch "/api/admin/v1/recharge_products/#{recharge_product.id}", params: {
        recharge_product: { name: '更新充值' }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新充值')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/recharge_products/#{recharge_product.id}", params: {
        recharge_product: { name: '' }
      }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/admin/v1/recharge_products/:id' do
    it 'deletes the recharge product' do
      recharge_product
      expect {
        delete "/api/admin/v1/recharge_products/#{recharge_product.id}", headers: auth_headers
      }.to change { Ddt::RechargeProduct.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('充值产品已删除')
    end
  end
end
