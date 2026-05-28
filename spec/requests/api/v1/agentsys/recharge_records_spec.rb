require 'rails_helper'

RSpec.describe 'Api::V1::Agentsys::RechargeRecords', type: :request do
  let(:agent) { create(:agent) }

  describe 'GET /api/v1/agent/recharge_records' do
    it 'returns recharge records' do
      get '/api/v1/agent/recharge_records', headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)
    end

    it 'filters by shop_id' do
      shop = create(:shop, agent_no: agent.agent_no)

      get '/api/v1/agent/recharge_records', params: { shop_id: shop.id }, headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /api/v1/agent/recharge_records' do
    it 'creates a recharge record' do
      shop = create(:shop, agent_no: agent.agent_no, expiration_time: 30.days.from_now)

      expect {
        post '/api/v1/agent/recharge_records', params: { shop_id: shop.id, increment_days: 30, recharge_type: 'base' }, headers: auth_headers(agent), as: :json
      }.to change(Ddt::ShopRechargeRecord, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end
end
