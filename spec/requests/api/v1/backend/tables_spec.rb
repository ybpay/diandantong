# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend Tables', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:table_zone) { create(:table_zone, shop: shop, branch: branch) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/tables' do
    it 'returns tables list' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/tables/:id' do
    let(:table) { create(:table, shop: shop, branch: branch, table_zone: table_zone) }

    it 'returns table details' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables/#{table.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(table.id)
    end

    it 'returns 404 for non-existent table' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/tables' do
    let(:valid_params) do
      {
        table: {
          name: 'A1',
          table_zone_id: table_zone.id,
          capacity: 4
        }
      }
    end

    it 'creates a table' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables",
             params: valid_params, headers: auth_headers
      }.to change { branch.tables.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('A1')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables",
           params: { table: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/tables/:id' do
    let(:table) { create(:table, shop: shop, branch: branch, table_zone: table_zone) }

    it 'updates a table' do
      patch "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables/#{table.id}",
            params: { table: { name: 'B2' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('B2')
    end
  end

  describe 'DELETE /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/tables/:id' do
    let!(:table) { create(:table, shop: shop, branch: branch, table_zone: table_zone) }

    it 'deletes a table' do
      expect {
        delete "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables/#{table.id}", headers: auth_headers
      }.to change { branch.tables.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('桌台已删除')
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/tables/:id/current_order' do
    let(:table) { create(:table, shop: shop, branch: branch, table_zone: table_zone) }

    it 'returns current order for table' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables/#{table.id}/current_order",
          headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/tables/:id/enable_qr_code' do
    let(:table) { create(:table, shop: shop, branch: branch, table_zone: table_zone) }

    it 'enables qr code' do
      put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables/#{table.id}/enable_qr_code",
          headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/tables/:id/disable_qr_code' do
    let(:table) { create(:table, shop: shop, branch: branch, table_zone: table_zone) }

    it 'disables qr code' do
      put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables/#{table.id}/disable_qr_code",
          headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/tables/:id/regenerate_qr_code' do
    let(:table) { create(:table, shop: shop, branch: branch, table_zone: table_zone) }

    it 'regenerates qr code' do
      put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables/#{table.id}/regenerate_qr_code",
          headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/branches/:branch_id/store/tables/batch_create' do
    let(:valid_params) do
      {
        batch_create_table_form: {
          start_name: 'C',
          count: 5,
          table_zone_id: table_zone.id,
          capacity: 4
        }
      }
    end

    it 'batch creates tables' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables/batch_create",
             params: valid_params, headers: auth_headers
      }.to change { branch.tables.count }.by(5)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('批量创建成功')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/store/tables/batch_create",
           params: { batch_create_table_form: { count: 0 } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
