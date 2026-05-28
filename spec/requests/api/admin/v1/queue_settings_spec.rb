# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 QueueSettings', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:queue_setting) { create(:queue_setting, shop: shop, branch: branch) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/queue_settings' do
    it 'returns queue settings list' do
      queue_setting
      get '/api/admin/v1/queue_settings', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/queue_settings'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/admin/v1/queue_settings/:id' do
    it 'returns queue setting details' do
      get "/api/admin/v1/queue_settings/#{queue_setting.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(queue_setting.id)
    end

    it 'returns 404 for non-existent queue setting' do
      get '/api/admin/v1/queue_settings/999999', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/admin/v1/queue_settings' do
    it 'creates a new queue setting' do
      expect {
        post '/api/admin/v1/queue_settings', params: {
          branch_id: branch.id,
          queue_setting: { name: '新排队', guest_num_le: 4, start_at: '09:00', end_at: '22:00' }
        }, headers: auth_headers
      }.to change { Ddt::QueueSetting.count }.by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('新排队')
    end

    it 'returns errors for invalid params' do
      post '/api/admin/v1/queue_settings', params: { queue_setting: { name: '' } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      post '/api/admin/v1/queue_settings', params: { queue_setting: { name: 'test' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/queue_settings/:id' do
    it 'updates queue setting name' do
      patch "/api/admin/v1/queue_settings/#{queue_setting.id}", params: {
        queue_setting: { name: '更新排队' }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('更新排队')
    end

    it 'returns errors for invalid params' do
      patch "/api/admin/v1/queue_settings/#{queue_setting.id}", params: {
        queue_setting: { name: '' }
      }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/admin/v1/queue_settings/:id' do
    it 'deletes the queue setting' do
      queue_setting
      expect {
        delete "/api/admin/v1/queue_settings/#{queue_setting.id}", headers: auth_headers
      }.to change { Ddt::QueueSetting.count }.by(-1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['message']).to eq('排队设置已删除')
    end
  end
end
