# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Account, type: :model do
  describe 'associations' do
    it { should belong_to(:shop) }
    it { should have_many(:roles) }
    it { should have_many(:manageships).dependent(:destroy) }
    it { should have_many(:manage_branches).through(:manageships) }
    it { should have_many(:push_channels) }
    it { should have_many(:shifts) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:login_id) }
    it { should validate_uniqueness_of(:login_id).case_insensitive }
    it { should validate_length_of(:name).is_at_most(50) }
  end

  describe 'devise modules' do
    it 'includes database_authenticatable' do
      expect(described_class.devise_modules).to include(:database_authenticatable)
    end

    it 'includes recoverable' do
      expect(described_class.devise_modules).to include(:recoverable)
    end

    it 'includes trackable' do
      expect(described_class.devise_modules).to include(:trackable)
    end
  end

  describe '#managed_branches' do
    let(:shop) { create(:shop_with_boss) }
    let(:account) { shop.accounts.first }

    it 'returns all branches for boss accounts' do
      expect(account.managed_branches).to eq(shop.branches)
    end
  end
end
