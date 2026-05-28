require 'rails_helper'

RSpec.describe 'Api::V1::Agentsys::CurrentAgent', type: :request do
  let(:agent) { create(:agent) }

  describe 'GET /api/v1/agent/user' do
    it 'returns current agent info' do
      get '/api/v1/agent/user', headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['data']['email']).to eq(agent.email)
      expect(json['data']['name']).to eq(agent.name)
    end

    it 'returns 401 without auth' do
      get '/api/v1/agent/user', as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
