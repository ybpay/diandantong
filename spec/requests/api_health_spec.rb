# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Health Check', type: :request do
  describe 'GET /up' do
    it 'returns success' do
      get '/up'
      expect(response).to have_http_status(:success)
    end
  end
end

RSpec.describe 'Error pages', type: :request do
  describe 'GET /404' do
    it 'returns not found' do
      get '/404'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /422' do
    it 'returns unprocessable entity' do
      get '/422'
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET /500' do
    it 'returns internal server error' do
      get '/500'
      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
