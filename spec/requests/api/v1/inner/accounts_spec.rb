# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Inner Accounts', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  before do
    allow(ApiAuth).to receive(:authentic?).and_return(true)
    allow(ApiAuth).to receive(:access_id).and_return('test_api_key')
    allow(Ddt::ApiKey).to receive(:find_by_id).with('test_api_key').and_return(
      Ddt::ApiKey.new(name: 'test', access_token: 'test_secret')
    )
  end

  describe 'GET /api/v1/inner/accounts' do
    it 'returns a successful response' do
      get '/api/v1/inner/accounts'
      expect(response).to have_http_status(:ok)
    end

    it 'returns accounts as an array' do
      get '/api/v1/inner/accounts'
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to be_an(Array)
    end
  end

  describe 'GET /api/v1/inner/accounts/:id' do
    it 'returns the account details' do
      get "/api/v1/inner/accounts/#{boss.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(boss.id)
    end

    it 'returns 404 for a non-existent account' do
      get '/api/v1/inner/accounts/999999'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/inner/accounts/authenticate' do
    context 'with valid credentials' do
      it 'authenticates and returns account info' do
        post '/api/v1/inner/accounts/authenticate',
             params: { login_id: boss.login_id, password: 'password123' }, as: :json
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid credentials' do
      it 'returns an error for wrong password' do
        post '/api/v1/inner/accounts/authenticate',
             params: { login_id: boss.login_id, password: 'wrong_password' }, as: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error for missing login_id' do
        post '/api/v1/inner/accounts/authenticate',
             params: { password: 'password123' }, as: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with role constraint' do
      it 'returns an error when account does not have the required role' do
        worker_account = create(:account, shop: shop)
        worker_role = Ddt::Role::Worker.create!(shop: shop, name: 'worker', builtin: true)
        worker_account.roles << worker_role

        post '/api/v1/inner/accounts/authenticate',
             params: { login_id: worker_account.login_id, password: 'password123', role: 'admin' }, as: :json
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'authentication requirement' do
    before do
      allow(ApiAuth).to receive(:authentic?).and_return(false)
    end

    it 'returns 401 without valid API key' do
      get '/api/v1/inner/accounts'
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
