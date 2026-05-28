# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 TableZones', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:table_zone) { create(:table_zone, shop: shop, branch: branch) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/table_zones' do
    it 'returns table zones list' do
      table_zone
      get '/api/admin/v1/table_zones', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/table_zones'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/table_zones/:id' do
    it 'returns table zone details with tables' do
      get "/api/admin/v1/table_zones/#{table_zone.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(table_zone.id)
    end

    it 'returns 404 for non-existent table zone' do
      get '/api/admin/v1/table_zones/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/table_zones' do
    it 'creates a new table zone' do
      expect {
        post '/api/admin/v1/table_zones', params: {
          table_zone: { name: '新区域', branch_id: branch.id }
        }, headers: auth_headers
      }.to change { Ddt::TableZone.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新区域')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/table_zones', params: { table_zone: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/table_zones', params: { table_zone: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/table_zones/:id' do
    it 'updates table zone name' do
      patch "/api/admin/v1/table_zones/#{table_zone.id}", params: {
        table_zone: { name: '更新区域' }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新区域')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/table_zones/#{table_zone.id}", params: {
        table_zone: { name: '' }
      }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/admin/v1/table_zones/:id' do
    it 'deletes the table zone' do
      table_zone
      expect {
        delete "/api/admin/v1/table_zones/#{table_zone.id}", headers: auth_headers
      }.to change { Ddt::TableZone.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('餐区已删除')
    end
  end
end
