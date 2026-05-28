require 'rails_helper'

RSpec.describe 'Api::V1::Agentsys::Merchants', type: :request do
  let(:agent) { create(:agent) }

  describe 'GET /api/v1/agent/merchants' do
    it 'returns a list of merchants' do
      create(:shop, agent_no: agent.agent_no, name: '测试餐厅A')

      get '/api/v1/agent/merchants', headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['merchants']).to be_an(Array)
      expect(json['total']).to be >= 1
    end

    it 'filters by keyword' do
      create(:shop, agent_no: agent.agent_no, name: '测试餐厅A')
      create(:shop, agent_no: agent.agent_no, name: '其他餐厅B')

      get '/api/v1/agent/merchants', params: { keyword: '测试' }, headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['merchants'].length).to be >= 1
    end

    it 'filters by status' do
      create(:shop, agent_no: agent.agent_no, name: '活跃餐厅', is_give_up: false, expiration_time: 1.year.from_now)

      get '/api/v1/agent/merchants', params: { status: 'active' }, headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['merchants'].all? { |m| m['status'] == 'active' }).to be true
    end
  end

  describe 'GET /api/v1/agent/merchants/:id' do
    it 'returns merchant details' do
      shop = create(:shop, agent_no: agent.agent_no)

      get "/api/v1/agent/merchants/#{shop.id}", headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['data']['id']).to eq(shop.id)
    end
  end

  describe 'POST /api/v1/agent/merchants/:id/renew' do
    it 'renews a merchant subscription' do
      shop = create(:shop, agent_no: agent.agent_no, expiration_time: 30.days.from_now)

      post "/api/v1/agent/merchants/#{shop.id}/renew", params: { days: 30 }, headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['data']['message']).to eq('续费成功')
    end
  end

  describe 'PUT /api/v1/agent/merchants/:id/suspend' do
    it 'suspends a merchant' do
      shop = create(:shop, agent_no: agent.agent_no)

      put "/api/v1/agent/merchants/#{shop.id}/suspend", headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      expect(shop.reload.is_give_up).to be true
    end
  end

  describe 'PUT /api/v1/agent/merchants/:id/activate' do
    it 'activates a merchant' do
      shop = create(:shop, agent_no: agent.agent_no, is_give_up: true)

      put "/api/v1/agent/merchants/#{shop.id}/activate", headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      expect(shop.reload.is_give_up).to be false
    end
  end

  describe 'POST /api/v1/agent/merchants/:id/reset_password' do
    it 'resets the merchant password' do
      shop = create(:shop_with_boss, agent_no: agent.agent_no)

      post "/api/v1/agent/merchants/#{shop.id}/reset_password", headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)
    end
  end
end
