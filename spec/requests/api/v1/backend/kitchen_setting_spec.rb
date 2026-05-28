# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend KitchenSetting', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/kitchen_setting' do
    before { Ddt::KitchenSetting.find_or_create_by!(branch: branch, warning_wait_minitue: 30) }

    it 'returns kitchen setting' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/kitchen_setting", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/kitchen_setting"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/kitchen_setting' do
    before { Ddt::KitchenSetting.find_or_create_by!(branch: branch, warning_wait_minitue: 30) }

    it 'updates kitchen setting' do
      patch "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/kitchen_setting",
            params: { kitchen_setting: { warning_wait_minitue: 30 } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['warning_wait_minitue']).to eq(30)
    end

    it 'returns 422 with invalid params' do
      patch "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/kitchen_setting",
            params: { kitchen_setting: { warning_wait_minitue: -1 } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
