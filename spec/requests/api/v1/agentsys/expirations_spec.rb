require 'rails_helper'

RSpec.describe 'Api::V1::Agentsys::Expirations', type: :request do
  let(:agent) { create(:agent) }

  describe 'GET /api/v1/agent/merchants/expirations' do
    it 'returns expiring merchants with summary' do
      create(:shop, agent_no: agent.agent_no, expiration_time: 5.days.from_now, is_give_up: false)

      get '/api/v1/agent/merchants/expirations', headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['merchants']).to be_an(Array)
      expect(json['summary']).to be_present
      expect(json['summary']['expired']).to be >= 0
      expect(json['total']).to be >= 0
    end

    it 'filters by expired status' do
      create(:shop, agent_no: agent.agent_no, expiration_time: 1.day.ago, is_give_up: false)

      get '/api/v1/agent/merchants/expirations', params: { filter: 'expired' }, headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['merchants'].length).to be >= 1
    end
  end
end
