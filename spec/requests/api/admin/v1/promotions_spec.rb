# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Promotions', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/promotions' do
    it 'returns promotions list' do
      get '/api/admin/v1/promotions', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/promotions'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/promotions/:id' do
    let(:promotion) do
      Ddt::EventPromotion.create!(shop: shop, name: '测试促销', start_at: Time.current, end_at: 1.week.from_now)
    end

    it 'returns promotion details' do
      get "/api/admin/v1/promotions/#{promotion.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(promotion.id)
    end

    it 'returns 404 for non-existent promotion' do
      get '/api/admin/v1/promotions/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/promotions' do
    it 'creates a new promotion' do
      expect {
        post '/api/admin/v1/promotions', params: {
          promotion: { name: '新促销', start_at: Time.current, end_at: 1.week.from_now }
        }, headers: auth_headers
      }.to change { Ddt::EventPromotion.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新促销')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/promotions', params: { promotion: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/promotions', params: { promotion: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/promotions/:id' do
    let(:promotion) do
      Ddt::EventPromotion.create!(shop: shop, name: '测试促销', start_at: Time.current, end_at: 1.week.from_now)
    end

    it 'updates promotion name' do
      patch "/api/admin/v1/promotions/#{promotion.id}", params: {
        promotion: { name: '更新促销' }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新促销')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/promotions/#{promotion.id}", params: {
        promotion: { name: '' }
      }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/admin/v1/promotions/:id' do
    let(:promotion) do
      Ddt::EventPromotion.create!(shop: shop, name: '测试促销', start_at: Time.current, end_at: 1.week.from_now)
    end

    it 'deletes the promotion' do
      promotion
      expect {
        delete "/api/admin/v1/promotions/#{promotion.id}", headers: auth_headers
      }.to change { Ddt::EventPromotion.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('促销活动已删除')
    end
  end
end
