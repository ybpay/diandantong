# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Inner Printers', type: :request do
  before do
    allow(ApiAuth).to receive(:authentic?).and_return(true)
    allow(ApiAuth).to receive(:access_id).and_return('test_api_key')
    allow(Ddt::ApiKey).to receive(:find_by_id).with('test_api_key').and_return(
      Ddt::ApiKey.new(name: 'test', access_token: 'test_secret')
    )
  end

  describe 'POST /api/v1/inner/printers/notify_error' do
    it 'returns 200 when printer exists' do
      printer = instance_double(Ddt::Printer)
      allow(Ddt::Printer).to receive_message_chain(:active, :where).and_return([printer])
      allow(printer).to receive(:notify_error)

      post '/api/v1/inner/printers/notify_error',
           params: { printer_code: 'PRN001', print_state: 'error', print_state_reason: 'paper_jam' }, as: :json
      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 when printer does not exist' do
      allow(Ddt::Printer).to receive_message_chain(:active, :where).and_return([])

      post '/api/v1/inner/printers/notify_error',
           params: { printer_code: 'NONEXISTENT', print_state: 'error', print_state_reason: 'paper_jam' }, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/inner/printers/notify_not_working' do
    it 'returns 200 when printer exists' do
      printer = instance_double(Ddt::Printer)
      allow(Ddt::Printer).to receive_message_chain(:active, :where).and_return([printer])
      allow(printer).to receive(:notify_not_working)

      post '/api/v1/inner/printers/notify_not_working',
           params: { printer_code: 'PRN001', last_print_success_at: '2026-01-01T00:00:00Z' }, as: :json
      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 when printer does not exist' do
      allow(Ddt::Printer).to receive_message_chain(:active, :where).and_return([])

      post '/api/v1/inner/printers/notify_not_working',
           params: { printer_code: 'NONEXISTENT', last_print_success_at: '2026-01-01T00:00:00Z' }, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/inner/printers/batch_notify_not_working' do
    it 'returns 200 with printers param' do
      printer = instance_double(Ddt::Printer, number: 'PRN001')
      allow(Ddt::Printer).to receive_message_chain(:active, :where).and_return([printer])
      allow(printer).to receive(:notify_not_working)

      post '/api/v1/inner/printers/batch_notify_not_working',
           params: {
             printers: { 'PRN001' => '2026-01-01T00:00:00Z' }
           }, as: :json
      expect(response).to have_http_status(:ok)
    end

    it 'returns 200 even without printers param' do
      post '/api/v1/inner/printers/batch_notify_not_working', as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'authentication requirement' do
    before do
      allow(ApiAuth).to receive(:authentic?).and_return(false)
    end

    it 'returns 401 without valid API key on notify_error' do
      post '/api/v1/inner/printers/notify_error',
           params: { printer_code: 'PRN001' }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 without valid API key on notify_not_working' do
      post '/api/v1/inner/printers/notify_not_working',
           params: { printer_code: 'PRN001' }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 without valid API key on batch_notify_not_working' do
      post '/api/v1/inner/printers/batch_notify_not_working', as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
