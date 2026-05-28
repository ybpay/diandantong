# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend DiscountPlans', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/marketing/discount_plans' do
    it 'returns discount plans list' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/marketing/discount_plans", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/marketing/discount_plans"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/marketing/discount_plans/:id' do
    let(:discount_plan) { Ddt::DiscountPlan.create!(branch: branch, shop: shop, name: '测试折扣') }

    it 'returns discount plan details' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/marketing/discount_plans/#{discount_plan.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(discount_plan.id)
    end

    it 'returns 404 for non-existent discount plan' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/marketing/discount_plans/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/branches/:branch_id/marketing/discount_plans' do
    let(:valid_params) do
      {
        discount_plan: {
          name: '午间折扣',
          start_at: '11:00',
          end_at: '14:00',
          enable_on_monday: true,
          enable_on_tuesday: true,
          enable_on_wednesday: true,
          enable_on_thursday: true,
          enable_on_friday: true,
          enable_on_saturday: false,
          enable_on_sunday: false
        }
      }
    end

    it 'creates a discount plan' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/marketing/discount_plans",
             params: valid_params, headers: auth_headers
      }.to change { branch.discount_plans.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('午间折扣')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/marketing/discount_plans",
           params: { discount_plan: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/branches/:branch_id/marketing/discount_plans/:id' do
    let(:discount_plan) { Ddt::DiscountPlan.create!(branch: branch, shop: shop, name: '测试折扣') }

    it 'updates a discount plan' do
      patch "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/marketing/discount_plans/#{discount_plan.id}",
            params: { discount_plan: { name: '更新折扣' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新折扣')
    end
  end

  describe 'DELETE /api/v1/backend/shops/:shop_slug/branches/:branch_id/marketing/discount_plans/:id' do
    let!(:discount_plan) { Ddt::DiscountPlan.create!(branch: branch, shop: shop, name: '测试折扣') }

    it 'deletes a discount plan' do
      expect {
        delete "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/marketing/discount_plans/#{discount_plan.id}", headers: auth_headers
      }.to change { branch.discount_plans.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('折扣方案已删除')
    end
  end
end
