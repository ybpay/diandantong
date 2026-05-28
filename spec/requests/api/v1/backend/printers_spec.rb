# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend Printers', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/printers' do
    it 'returns printers list' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/printers", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/printers"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/printers/:id' do
    let(:printer) { Ddt::Printer.create!(shop: shop, branch: branch, name: '测试打印机', use_scene: 'kitchen') }

    it 'returns printer details' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/printers/#{printer.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(printer.id)
    end

    it 'returns 404 for non-existent printer' do
      get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/printers/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/backend/shops/:shop_slug/branches/:branch_id/printers' do
    let(:valid_params) do
      {
        printer: {
          name: '测试打印机',
          printer_type: 'feiyin',
          use_scene: 'kitchen',
          copies: 1
        }
      }
    end

    it 'creates a printer' do
      expect {
        post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/printers",
             params: valid_params, headers: auth_headers
      }.to change { branch.printers.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('测试打印机')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/printers",
           params: { printer: { name: '', use_scene: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/backend/shops/:shop_slug/branches/:branch_id/printers/:id' do
    let(:printer) { Ddt::Printer.create!(shop: shop, branch: branch, name: '测试打印机', use_scene: 'kitchen') }

    it 'updates a printer' do
      patch "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/printers/#{printer.id}",
            params: { printer: { name: '更新打印机' } }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新打印机')
    end
  end

  describe 'DELETE /api/v1/backend/shops/:shop_slug/branches/:branch_id/printers/:id' do
    let!(:printer) { Ddt::Printer.create!(shop: shop, branch: branch, name: '测试打印机', use_scene: 'kitchen') }

    it 'deletes a printer' do
      expect {
        delete "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/printers/#{printer.id}", headers: auth_headers
      }.to change { branch.printers.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('打印机已删除')
    end
  end
end
