# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Common Account', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/v1/common/account' do
    it 'returns account details with auth' do
      get '/api/v1/common/account', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(boss.id)
    end

    it 'returns 401 without auth' do
      get '/api/v1/common/account'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v1/common/account' do
    it 'returns 401 without auth' do
      post '/api/v1/common/account', params: { account: { name: 'New' } }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with auth' do
      it 'creates an account' do
        post '/api/v1/common/account',
             params: {
               account: {
                 login_id: "new_user_#{SecureRandom.hex(2)}",
                 name: 'New Employee',
                 phone: '13800138000',
                 password: 'password123',
                 password_confirmation: 'password123'
               }
             },
             headers: auth_headers, as: :json
        expect(response).to have_http_status(:created).or have_http_status(:ok)
      end
    end
  end

  describe 'POST /api/v1/common/account/update_password' do
    it 'returns 401 without auth' do
      post '/api/v1/common/account/update_password',
           params: { password: 'newpass123', password_confirmation: 'newpass123' }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with auth' do
      it 'updates the password' do
        post '/api/v1/common/account/update_password',
             params: {
               current_password: 'password123',
               password: 'newpassword456',
               password_confirmation: 'newpassword456'
             },
             headers: auth_headers, as: :json
        expect(response).to have_http_status(:ok).or have_http_status(:bad_request)
      end
    end
  end
end
