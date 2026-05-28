# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Table, type: :model do
  let(:shop) { create(:shop_with_boss) }
  let(:branch) { shop.branches.first }
  let(:table_zone) { create(:table_zone, shop: shop, branch: branch) }

  describe 'associations' do
    it { should belong_to(:table_zone) }
    it { should have_many(:orders) }
    it { should have_and_belong_to_many(:printers) }
    it { should have_many(:order_itemables) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:table_zone) }
    it { should validate_presence_of(:capacity) }
    it { should validate_numericality_of(:capacity).is_greater_than(0) }
  end

  describe 'included modules' do
    it 'includes Discard::Model' do
      expect(described_class.ancestors).to include(Discard::Model)
    end

    it 'includes AASM' do
      expect(described_class.ancestors).to include(AASM)
    end
  end

  describe 'AASM states' do
    let(:table) { create(:table, shop: shop, branch: branch, table_zone: table_zone) }

    it 'starts in idle state' do
      expect(table.workflow_state).to eq('idle')
    end

    it 'transitions from idle to opened' do
      expect(table.may_open?).to be true
    end

    it 'transitions from opened to ordered' do
      table.update!(workflow_state: 'opened')
      expect(table.may_order?).to be true
    end

    it 'transitions from ordered to check_outing' do
      table.update!(workflow_state: 'ordered')
      expect(table.may_check_out?).to be true
    end

    it 'transitions from check_outing to paid' do
      table.update!(workflow_state: 'check_outing')
      expect(table.may_pay?).to be true
    end

    it 'transitions from ordered to idle (cancel)' do
      table.update!(workflow_state: 'ordered')
      expect(table.may_cancel?).to be true
    end

    it 'transitions from paid to idle (clear)' do
      table.update!(workflow_state: 'paid')
      expect(table.may_clear?).to be true
    end

    it 'can force clear from any active state' do
      %w[opened ordered check_outing paid].each do |state|
        table.update!(workflow_state: state)
        expect(table.may_force_clear?).to be true
      end
    end

    it 'transitions from check_outing back to ordered (cancel_check_out)' do
      table.update!(workflow_state: 'check_outing')
      expect(table.may_cancel_check_out?).to be true
    end
  end

  describe '#active?' do
    it 'returns true for opened state' do
      table = create(:table, shop: shop, branch: branch, table_zone: table_zone, workflow_state: 'opened')
      expect(table.active?).to be true
    end

    it 'returns true for ordered state' do
      table = create(:table, shop: shop, branch: branch, table_zone: table_zone, workflow_state: 'ordered')
      expect(table.active?).to be true
    end

    it 'returns false for idle state' do
      table = create(:table, shop: shop, branch: branch, table_zone: table_zone, workflow_state: 'idle')
      expect(table.active?).to be false
    end
  end

  describe '#name_with_zone' do
    it 'includes zone name and table name' do
      table = create(:table, shop: shop, branch: branch, table_zone: table_zone, name: 'A1')
      expect(table.name_with_zone).to include('A1')
    end
  end

  describe 'Discard::Model' do
    it 'soft deletes a table' do
      table = create(:table, shop: shop, branch: branch, table_zone: table_zone)
      table.discard!
      expect(table.discarded?).to be true
    end
  end

  describe 'factory' do
    it 'creates a valid table' do
      table = create(:table, shop: shop, branch: branch, table_zone: table_zone)
      expect(table).to be_persisted
      expect(table.name).to be_present
      expect(table.capacity).to be > 0
    end
  end
end
