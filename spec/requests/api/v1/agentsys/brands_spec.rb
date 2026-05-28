require 'rails_helper'

RSpec.describe 'Api::V1::Agentsys::Brands', type: :request do
  let(:agent) { create(:agent) }
  let(:headers) { auth_headers(agent) }

  describe 'GET /api/v1/agent/brands' do
    context 'when agent is not OEM' do
      it 'returns empty array' do
        get '/api/v1/agent/brands', headers: headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq([])
      end
    end

    context 'when agent is OEM' do
      let(:oem_agent) { create(:agent, :oem) }
      let(:headers) { auth_headers(oem_agent) }

      it 'returns brands' do
        get '/api/v1/agent/brands', headers: headers, as: :json
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /api/v1/agent/brands' do
    context 'when agent is not OEM' do
      it 'returns 403' do
        post '/api/v1/agent/brands', params: { name: 'Test Brand' }, headers: headers, as: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
