# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Shift, type: :model do
  let(:shop) { create(:shop_with_boss) }
  let(:branch) { shop.branches.first }
  let(:account) { shop.accounts.first }

  describe 'associations' do
    it { should belong_to(:account) }
    it { should have_many(:shift_items).dependent(:destroy) }
    it { should have_many(:base_shift_items) }
    it { should have_many(:recharge_shift_items) }
  end

  describe 'included modules' do
    it 'includes Discard::Model' do
      expect(described_class.ancestors).to include(Discard::Model)
    end
  end

  describe 'acts_as_type :state' do
    it 'defines opening state' do
      shift = build(:shift, shop: shop, branch: branch, account: account, state: 'opening')
      expect(shift.is_opening?).to be true
    end

    it 'defines closed state' do
      shift = build(:shift, shop: shop, branch: branch, account: account, state: 'closed')
      expect(shift.is_closed?).to be true
    end
  end

  describe 'scopes' do
    let!(:opening_shift) { create(:shift, shop: shop, branch: branch, account: account, state: 'opening') }
    let!(:closed_shift) { create(:shift, shop: shop, branch: branch, account: account, state: 'closed') }

    it '.opening returns opening shifts' do
      expect(described_class.opening).to include(opening_shift)
      expect(described_class.opening).not_to include(closed_shift)
    end

    it '.closed returns closed shifts' do
      expect(described_class.closed).to include(closed_shift)
      expect(described_class.closed).not_to include(opening_shift)
    end
  end

  describe '#open' do
    it 'sets state to opening after create' do
      shift = create(:shift, shop: shop, branch: branch, account: account)
      expect(shift.state).to eq('opening')
    end
  end

  describe '#close' do
    it 'transitions state to closed' do
      shift = create(:shift, shop: shop, branch: branch, account: account)
      shift.close
      expect(shift.state).to eq('closed')
    end
  end

  describe '#update_amount' do
    it 'updates total_amount' do
      shift = create(:shift, shop: shop, branch: branch, account: account)
      shift.update_amount(total_amount: 1000.0)
      expect(shift.total_amount.to_f).to eq(1000.0)
    end
  end

  describe '#shift_closed_at' do
    it 'returns closed_at when closed' do
      closed_time = 1.hour.ago
      shift = create(:shift, shop: shop, branch: branch, account: account, state: 'closed', closed_at: closed_time)
      expect(shift.shift_closed_at).to be_present
    end
  end

  describe 'Discard::Model' do
    it 'soft deletes a shift' do
      shift = create(:shift, shop: shop, branch: branch, account: account)
      shift.discard!
      expect(shift.discarded?).to be true
    end
  end

  describe 'factory' do
    it 'creates a valid shift' do
      shift = create(:shift, shop: shop, branch: branch, account: account)
      expect(shift).to be_persisted
      expect(shift.state).to eq('opening')
    end
  end
end
