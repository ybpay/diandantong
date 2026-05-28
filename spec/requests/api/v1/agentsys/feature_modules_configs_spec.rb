require 'rails_helper'

RSpec.describe 'Api::V1::Agentsys::FeatureModulesConfigs', type: :request do
  let(:agent) { create(:agent) }
  let(:headers) { auth_headers(agent) }

  describe 'GET /api/v1/agent/feature_modules_configs' do
    it 'returns configs when shop_id provided' do
      get '/api/v1/agent/feature_modules_configs', params: { shop_id: 0 }, headers: headers, as: :json
      expect(response).to have_http_status(:ok)
    end

    it 'returns empty array without shop_id' do
      get '/api/v1/agent/feature_modules_configs', headers: headers, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']).to eq([])
    end
  end
end
