# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 DiscountPlan', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:discount_plan) do
    Ddt::DiscountPlan.create!(shop: shop, branch: branch, name: '测试折扣')
  end

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/discount_plan' do
    it 'returns discount plan details' do
      discount_plan
      get '/api/admin/v1/discount_plan', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/discount_plan'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/admin/v1/discount_plan' do
    it 'creates a new discount plan' do
      expect {
        post '/api/admin/v1/discount_plan', params: {
          branch_id: branch.id,
          discount_plan: { name: '新折扣方案' }
        }, headers: auth_headers
      }.to change { Ddt::DiscountPlan.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新折扣方案')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/discount_plan', params: {
        discount_plan: { name: '' }
      }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/discount_plan', params: { discount_plan: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/discount_plan' do
    it 'updates discount plan' do
      discount_plan
      patch '/api/admin/v1/discount_plan', params: {
        discount_plan: { name: '更新折扣方案' }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新折扣方案')
    end

    it 'returns errors for invalid params' do
      discount_plan
      patch '/api/admin/v1/discount_plan', params: {
        discount_plan: { name: '' }
      }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/admin/v1/discount_plan' do
    it 'deletes the discount plan' do
      discount_plan
      expect {
        delete '/api/admin/v1/discount_plan', headers: auth_headers
      }.to change { Ddt::DiscountPlan.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('折扣方案已删除')
    end
  end
end
