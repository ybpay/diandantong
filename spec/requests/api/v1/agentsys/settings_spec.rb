require 'rails_helper'

RSpec.describe 'Api::V1::Agentsys::Settings', type: :request do
  let(:agent) { create(:agent) }

  describe 'GET /api/v1/agent/settings' do
    it 'returns agent settings' do
      get '/api/v1/agent/settings', headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['name']).to be_present
      expect(json['email']).to be_present
      expect(json['agent_level']).to be_present
    end
  end

  describe 'PUT /api/v1/agent/settings/profile' do
    it 'updates agent profile' do
      put '/api/v1/agent/settings/profile', params: { name: '新名称', phone: '13800000000' }, headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      expect(agent.reload.name).to eq('新名称')
    end
  end

  describe 'PUT /api/v1/agent/settings/password' do
    it 'updates password with valid current password' do
      put '/api/v1/agent/settings/password', params: { current_password: 'password123', new_password: 'newpassword123' }, headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)
    end

    it 'rejects wrong current password' do
      put '/api/v1/agent/settings/password', params: { current_password: 'wrong', new_password: 'newpassword123' }, headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
