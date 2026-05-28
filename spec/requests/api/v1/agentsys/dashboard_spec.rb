require 'rails_helper'

RSpec.describe 'Api::V1::Agentsys::Dashboard', type: :request do
  let(:agent) { create(:agent) }

  describe 'GET /api/v1/agent/dashboard' do
    it 'returns dashboard stats' do
      shop = create(:shop, agent_no: agent.agent_no, expiration_time: 1.year.from_now)

      get '/api/v1/agent/dashboard', headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['stats']).to be_present
      expect(json['stats']['totalMerchants']).to be >= 0
      expect(json['recent_merchants']).to be_an(Array)
      expect(json['expiring_merchants']).to be_an(Array)
    end
  end
end
