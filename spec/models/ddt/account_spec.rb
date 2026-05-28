# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Account, type: :model do
  let(:shop) { create(:shop_with_boss) }

  describe 'associations' do
    it { should belong_to(:shop) }
    it { should have_many(:roles) }
    it { should have_many(:manageships).dependent(:destroy) }
    it { should have_many(:manage_branches).through(:manageships) }
    it { should have_many(:push_channels) }
    it { should have_many(:shifts) }
  end

  describe 'validations' do
    it { should validate_presence_of(:login_id) }
    it { should validate_presence_of(:email) }
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
    let(:account) { shop.accounts.first }

    it 'returns all branches for boss accounts' do
      expect(account.managed_branches).to eq(shop.branches)
    end
  end

  describe 'role methods' do
    let(:account) { create(:account, shop: shop) }

    context 'when account has boss role' do
      before do
        role = Ddt::Role::Boss.create!(shop: shop, name: 'boss', builtin: true)
        account.roles << role
      end

      it 'returns true for is_boss?' do
        expect(account.is_boss?).to be true
      end
    end

    context 'when account has no boss role' do
      it 'returns false for is_boss?' do
        expect(account.is_boss?).to be false
      end
    end
  end

  describe 'scopes' do
    let!(:boss) { create(:account, shop: shop) }

    before do
      role = Ddt::Role::Boss.create!(shop: shop, name: 'boss', builtin: true)
      boss.roles << role
    end

    it '.boss returns boss accounts' do
      expect(described_class.boss).to include(boss)
    end

    it '.bosses_and_workers returns accounts' do
      expect(described_class.bosses_and_workers).to include(boss)
    end
  end

  describe 'factory' do
    it 'creates a valid account with prefixed login_id' do
      account = create(:account, shop: shop)
      expect(account).to be_persisted
      expect(account.login_id).to include(':')
    end
  end
end
