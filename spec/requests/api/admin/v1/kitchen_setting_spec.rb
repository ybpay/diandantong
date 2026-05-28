# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 KitchenSetting', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/kitchen_setting' do
    it 'returns kitchen setting' do
      get '/api/admin/v1/kitchen_setting', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns kitchen setting for specific branch' do
      get "/api/admin/v1/kitchen_setting?branch_id=#{branch.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/kitchen_setting'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/kitchen_setting' do
    it 'updates kitchen setting' do
      patch '/api/admin/v1/kitchen_setting', params: {
        kitchen_setting: { warning_wait_minitue: 15 }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      patch '/api/admin/v1/kitchen_setting', params: { kitchen_setting: { warning_wait_minitue: 15 } }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
