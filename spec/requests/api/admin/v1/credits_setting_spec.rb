# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Admin V1 CreditsSetting', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  describe 'GET /api/admin/v1/credits_setting' do
    it 'returns credits setting' do
      get '/api/admin/v1/credits_setting', headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns 401 without auth' do
      get '/api/admin/v1/credits_setting'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/admin/v1/credits_setting' do
    it 'updates credits setting exchange radio' do
      patch '/api/admin/v1/credits_setting', params: {
        credits_setting: { exchange_radio: 100 }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
    end

    it 'returns errors for invalid params' do
      allow_any_instance_of(Ddt::CreditsSetting).to receive(:update).and_return(false)
      allow_any_instance_of(Ddt::CreditsSetting).to receive_message_chain(:errors, :map).and_return([])
      allow_any_instance_of(Ddt::CreditsSetting).to receive_message_chain(:errors, :full_messages).and_return(['Exchange radio is invalid'])
      patch '/api/admin/v1/credits_setting', params: {
        credits_setting: { exchange_radio: -1 }
      }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 without auth' do
      patch '/api/admin/v1/credits_setting', params: { credits_setting: { exchange_radio: 100 } }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
