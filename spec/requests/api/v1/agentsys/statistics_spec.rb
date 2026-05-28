require 'rails_helper'

RSpec.describe 'Api::V1::Agentsys::Statistics', type: :request do
  let(:agent) { create(:agent) }

  describe 'GET /api/v1/agent/statistics' do
    it 'returns statistics' do
      get '/api/v1/agent/statistics', headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['summary']).to be_present
      expect(json['summary']['newMerchants']).to be >= 0
      expect(json['summary']['totalRevenue']).to be_present
      expect(json['commissions']).to be_an(Array)
    end

    it 'accepts date range params' do
      get '/api/v1/agent/statistics', params: { start_date: '2026-01-01', end_date: '2026-05-28' }, headers: auth_headers(agent), as: :json
      expect(response).to have_http_status(:ok)
    end
  end
end
