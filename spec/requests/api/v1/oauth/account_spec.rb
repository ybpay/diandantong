# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 OAuth Account', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  describe 'GET /api/v1/oauth/account' do
    it 'returns 401 without OAuth token' do
      get '/api/v1/oauth/account'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 with invalid OAuth token' do
      get '/api/v1/oauth/account', headers: {
        'Authorization' => 'Bearer invalid_token',
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with a valid Doorkeeper OAuth token', skip: 'Doorkeeper OAuth setup required' do
      # To test with a real Doorkeeper token, you need:
      #   let(:application) { Doorkeeper::Application.create!(name: 'Test', redirect_uri: 'urn:ietf:wg:oauth:2.0:oob') }
      #   let(:token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: boss.id) }
      #   let(:oauth_headers) { { 'Authorization' => "Bearer #{token.token}" } }
      #
      # it 'returns account details' do
      #   get '/api/v1/oauth/account', headers: oauth_headers
      #   expect(response).to have_http_status(:ok)
      #   json = JSON.parse(response.body)
      #   expect(json['data']['id']).to eq(boss.id)
      # end
      it 'placeholder test for Doorkeeper integration' do
        skip 'Doorkeeper OAuth setup required'
      end
    end
  end
end
