# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend TableZones', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/table_zones' do
    it 'returns table zones list' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/table_zones", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/table_zones"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/table_zones/:id' do
    let(:table_zone) { create(:table_zone, shop: shop, branch: branch) }

    it 'returns table zone details' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/table_zones/#{table_zone.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(table_zone.id)
    end

    it 'returns 404 for non-existent table zone' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/table_zones/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/table_zones' do
    let(:valid_params) do
      {
        table_zone: {
          name: '大厅区',
          tables_count: 10
        }
      }
    end

    it 'creates a table zone' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/table_zones",
             params: valid_params, headers: auth_headers
      }.to change { branch.table_zones.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('大厅区')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/table_zones",
           params: { table_zone: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/table_zones/:id' do
    let(:table_zone) { create(:table_zone, shop: shop, branch: branch) }

    it 'updates a table zone' do
      patch "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/table_zones/#{table_zone.id}",
            params: { table_zone: { name: '更新区域' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新区域')
    end
  end

  describe 'DELETE /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/table_zones/:id' do
    let!(:table_zone) { create(:table_zone, shop: shop, branch: branch) }

    it 'deletes a table zone' do
      expect {
        delete "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/table_zones/#{table_zone.id}", headers: auth_headers
      }.to change { branch.table_zones.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('餐区已删除')
    end
  end
end
