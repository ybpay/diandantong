require 'rails_helper'

RSpec.describe 'Api::V1::Agentsys::SubAgents', type: :request do
  let(:agent) { create(:agent) }
  let(:headers) { auth_headers(agent) }

  describe 'GET /api/v1/agent/agents' do
    it 'returns sub agents' do
      get '/api/v1/agent/agents', headers: headers, as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /api/v1/agent/agents' do
    it 'creates a sub agent' do
      expect {
        post '/api/v1/agent/agents', params: {
          name: 'Sub Agent', email: 'sub@example.com',
          password: 'password123', phone: '13900001111'
        }, headers: headers, as: :json
      }.to change(Ddt::Agent, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end
end
