# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Tables', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:table_zone) { create(:table_zone, shop: shop, branch: branch) }
  let(:table) { create(:table, shop: shop, branch: branch, table_zone: table_zone) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/tables' do
    it 'returns tables list' do
      table
      get '/api/admin/v1/tables', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'filters by branch_id' do
      table
      get "/api/admin/v1/tables?branch_id=#{branch.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/tables'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/tables/:id' do
    it 'returns table details' do
      get "/api/admin/v1/tables/#{table.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(table.id)
    end

    it 'returns 404 for non-existent table' do
      get '/api/admin/v1/tables/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/tables' do
    it 'creates a new table' do
      expect {
        post '/api/admin/v1/tables', params: {
          branch_id: branch.id,
          table: { name: '新桌台', table_zone_id: table_zone.id, capacity: 6 }
        }, headers: auth_headers
      }.to change { Ddt::Table.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新桌台')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/tables', params: { table: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/tables', params: { table: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/tables/:id' do
    it 'updates table name' do
      patch "/api/admin/v1/tables/#{table.id}", params: {
        table: { name: '更新桌台' }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新桌台')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/tables/#{table.id}", params: {
        table: { name: '' }
      }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/admin/v1/tables/:id' do
    it 'deletes the table' do
      table
      expect {
        delete "/api/admin/v1/tables/#{table.id}", headers: auth_headers
      }.to change { Ddt::Table.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('桌台已删除')
    end
  end
end
