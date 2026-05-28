# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 Printers', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:printer) do
    Ddt::Printer.create!(shop: shop, branch: branch, name: '测试打印机', printer_type: 'normal', device_sn: 'SN001')
  end

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/printers' do
    it 'returns printers list' do
      printer
      get '/api/admin/v1/printers', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/printers'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/printers/:id' do
    it 'returns printer details' do
      get "/api/admin/v1/printers/#{printer.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(printer.id)
    end

    it 'returns 404 for non-existent printer' do
      get '/api/admin/v1/printers/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/printers' do
    it 'creates a new printer' do
      expect {
        post '/api/admin/v1/printers', params: {
          printer: { name: '新打印机', printer_type: 'normal', device_sn: 'SN002', branch_id: branch.id }
        }, headers: auth_headers
      }.to change { Ddt::Printer.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新打印机')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/printers', params: { printer: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/printers', params: { printer: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/printers/:id' do
    it 'updates printer name' do
      patch "/api/admin/v1/printers/#{printer.id}", params: {
        printer: { name: '更新打印机' }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新打印机')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/printers/#{printer.id}", params: {
        printer: { name: '' }
      }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/admin/v1/printers/:id' do
    it 'deletes the printer' do
      printer
      expect {
        delete "/api/admin/v1/printers/#{printer.id}", headers: auth_headers
      }.to change { Ddt::Printer.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('打印机已删除')
    end
  end
end
