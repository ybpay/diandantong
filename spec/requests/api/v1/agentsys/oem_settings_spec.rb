require 'rails_helper'

RSpec.describe 'Api::V1::Agentsys::OemSettings', type: :request do
  let(:agent) { create(:agent) }
  let(:headers) { auth_headers(agent) }

  describe 'GET /api/v1/agent/oem_settings' do
    context 'when agent is not OEM' do
      it 'returns 403' do
        get '/api/v1/agent/oem_settings', headers: headers, as: :json
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when agent is OEM' do
      let(:oem_agent) { create(:agent, :oem) }
      let(:headers) { auth_headers(oem_agent) }

      it 'returns OEM settings' do
        get '/api/v1/agent/oem_settings', headers: headers, as: :json
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['system_name']).to be_present
        expect(json['colors']).to be_present
      end
    end
  end
end
