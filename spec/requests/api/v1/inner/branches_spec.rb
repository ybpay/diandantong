# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Inner Branches', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let!(:product) { create(:product, shop: shop, branch: branch) }

  before do
    allow(ApiAuth).to receive(:authentic?).and_return(true)
    allow(ApiAuth).to receive(:access_id).and_return('test_api_key')
    allow(Ddt::ApiKey).to receive(:find_by_id).with('test_api_key').and_return(
      Ddt::ApiKey.new(name: 'test', access_token: 'test_secret')
    )
  end

  describe 'GET /api/v1/inner/branches' do
    it 'returns a successful response' do
      get '/api/v1/inner/branches', params: { current_account_id: boss.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /api/v1/inner/branches/:id' do
    it 'returns the branch details' do
      get "/api/v1/inner/branches/#{branch.id}", params: { current_account_id: boss.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /api/v1/inner/branches/:branch_id/products' do
    it 'returns products for the branch' do
      get "/api/v1/inner/branches/#{branch.id}/products", params: { current_account_id: boss.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'authentication requirement' do
    before do
      allow(ApiAuth).to receive(:authentic?).and_return(false)
    end

    it 'returns 401 without valid API key' do
      get '/api/v1/inner/branches'
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
