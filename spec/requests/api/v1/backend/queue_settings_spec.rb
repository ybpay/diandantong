# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend QueueSettings', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/queue_settings' do
    it 'returns queue settings list' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/queue_settings", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/queue_settings"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/queue_settings/:id' do
    let(:queue_setting) { create(:queue_setting, shop: shop, branch: branch) }

    it 'returns queue setting details' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/queue_settings/#{queue_setting.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(queue_setting.id)
    end

    it 'returns 404 for non-existent queue setting' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/queue_settings/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/queue_settings' do
    let(:valid_params) do
      {
        queue_setting: {
          name: '午间排队',
          guest_num_le: 4,
          start_at: '11:00',
          end_at: '14:00',
          queue_no_prefix: 'L',
          enabled: true,
          notify_number_in_advance: 3
        }
      }
    end

    it 'creates a queue setting' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/queue_settings",
             params: valid_params, headers: auth_headers
      }.to change { branch.queue_settings.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('午间排队')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/queue_settings",
           params: { queue_setting: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/queue_settings/:id' do
    let(:queue_setting) { create(:queue_setting, shop: shop, branch: branch) }

    it 'updates a queue setting' do
      patch "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/queue_settings/#{queue_setting.id}",
            params: { queue_setting: { name: '更新排队' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新排队')
    end
  end

  describe 'DELETE /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/queue_settings/:id' do
    let!(:queue_setting) { create(:queue_setting, shop: shop, branch: branch) }

    it 'deletes a queue setting' do
      expect {
        delete "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/queue_settings/#{queue_setting.id}", headers: auth_headers
      }.to change { branch.queue_settings.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('排队设置已删除')
    end
  end
end
