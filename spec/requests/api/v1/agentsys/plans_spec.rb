require 'rails_helper'

RSpec.describe 'Api::V1::Agentsys::Plans', type: :request do
  let(:agent) { create(:agent) }

  describe 'GET /api/v1/agent/plans' do
    it 'returns available plans' do
      get '/api/v1/agent/plans', headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json).to be_an(Array)
    end
  end
end
