# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Common Session', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'POST /api/v1/common/session' do
    context 'with valid credentials' do
      it 'creates a session and returns account info' do
        post '/api/v1/common/session', params: { login_id: boss.login_id, password: 'password123' }, as: :json
        expect(response).to have_http_status(:created).or have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']).to have_key('authentication_token')
      end
    end

    context 'with invalid credentials' do
      it 'returns an error for wrong password' do
        post '/api/v1/common/session', params: { login_id: boss.login_id, password: 'wrong_password' }, as: :json
        expect(response).to have_http_status(:bad_request).or have_http_status(:unauthorized)
      end

      it 'returns an error for non-existent login' do
        post '/api/v1/common/session', params: { login_id: 'nonexistent', password: 'password123' }, as: :json
        expect(response).to have_http_status(:bad_request).or have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/common/session' do
    it 'destroys the session' do
      delete '/api/v1/common/session', headers: auth_headers, as: :json
      expect(response).to have_http_status(:ok).or have_http_status(:no_content)
    end

    it 'returns 401 without auth' do
      delete '/api/v1/common/session', as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
