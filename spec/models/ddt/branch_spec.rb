# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Branch, type: :model do
  let(:shop) { create(:shop_with_boss) }
  let(:branch) { shop.branches.first }

  describe 'associations' do
    it { should belong_to(:shop) }
    it { should have_many(:products) }
    it { should have_many(:categories) }
    it { should have_many(:tables) }
    it { should have_many(:guest_queues) }
    it { should have_many(:orders) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'is_real scope' do
    it 'returns only real branches' do
      real = create(:branch, shop: shop, is_real: true)
      virtual = create(:branch, shop: create(:shop), is_real: false)
      expect(described_class.real).to include(real)
      expect(described_class.real).not_to include(virtual)
    end
  end

  describe 'geographic location' do
    it 'stores latitude and longitude' do
      branch = create(:branch, shop: shop, latitude: 31.23, longitude: 121.47)
      expect(branch.latitude).to eq(31.23)
      expect(branch.longitude).to eq(121.47)
    end
  end

  describe 'factory' do
    it 'creates a valid branch' do
      branch = create(:branch, shop: shop)
      expect(branch).to be_persisted
      expect(branch.name).to be_present
      expect(branch.is_real).to be true
    end
  end
end
