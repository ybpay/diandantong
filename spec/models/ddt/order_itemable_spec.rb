# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::OrderItemable, type: :model do
  let(:shop) { create(:shop_with_boss) }
  let(:branch) { shop.branches.first }

  describe 'associations' do
    it { should belong_to(:user).class_name('Ddt::BaseUser').optional }
    it { should belong_to(:itemable).optional }
    it { should belong_to(:guest_queue).optional }
    it { should belong_to(:table).optional }
  end

  describe 'validations' do
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
  end

  describe '#amount' do
    it 'calculates amount from quantity and price' do
      item = create(:order_itemable, shop: shop, branch: branch, quantity: 3)
      expect(item.amount).to be_present
    end
  end

  describe 'acts_as_type :store_type' do
    it 'provides scope for_pre_order' do
      expect(described_class).to respond_to(:for_pre_order)
    end

    it 'provides scope for_merge_order' do
      expect(described_class).to respond_to(:for_merge_order)
    end

    it 'provides scope for_wifi_order' do
      expect(described_class).to respond_to(:for_wifi_order)
    end
  end

  describe '#plus' do
    it 'increments quantity' do
      item = create(:order_itemable, shop: shop, branch: branch, quantity: 1)
      expect { item.plus }.to change { item.quantity }.by(1)
    end
  end

  describe '#minus' do
    it 'decrements quantity' do
      item = create(:order_itemable, shop: shop, branch: branch, quantity: 2)
      expect { item.minus }.to change { item.quantity }.by(-1)
    end
  end

  describe 'factory' do
    it 'creates a valid order itemable' do
      user = create(:user, shop: shop)
      item = create(:order_itemable, shop: shop, branch: branch, user: user, quantity: 2)
      expect(item).to be_persisted
      expect(item.quantity).to eq(2)
    end
  end
end
