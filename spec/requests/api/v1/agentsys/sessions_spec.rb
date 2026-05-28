require 'rails_helper'

RSpec.describe 'Api::V1::Agentsys::Sessions', type: :request do
  describe 'POST /api/v1/agent/auth/login' do
    let(:agent) { create(:agent) }

    context 'with valid credentials' do
      it 'returns a JWT token' do
        post '/api/v1/agent/auth/login', params: { email: agent.email, password: 'password123' }, as: :json
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['token']).to be_present
        expect(json['user']['email']).to eq(agent.email)
      end
    end

    context 'with invalid credentials' do
      it 'returns 401' do
        post '/api/v1/agent/auth/login', params: { email: agent.email, password: 'wrong' }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with expired agent' do
      let(:expired_agent) { create(:agent, :expired) }

      it 'returns 403' do
        post '/api/v1/agent/auth/login', params: { email: expired_agent.email, password: 'password123' }, as: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /api/v1/agent/auth/logout' do
    let(:agent) { create(:agent) }

    it 'returns success' do
      delete '/api/v1/agent/auth/logout', headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)
    end
  end
end
