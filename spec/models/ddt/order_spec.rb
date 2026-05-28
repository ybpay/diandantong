# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Order, type: :model do
  describe 'constants' do
    it 'defines cancel reasons' do
      expected = %w[货物售罄 地址无效 超出范围 无法配送 定单无效 其他原因]
      expect(described_class::CANCEL_REASONS).to eq(expected)
    end
  end
end

RSpec.describe Ddt::OrderService::Order::Base, type: :model do
  let(:shop) { create(:shop_with_boss) }
  let(:branch) { shop.branches.first }
  let(:user) { create(:user, shop: shop) }

  describe 'AASM states' do
    it 'starts in pending state' do
      order = described_class.new(shop: shop, branch: branch, user: user)
      expect(order.state).to eq('pending')
    end

    it 'transitions from pending to confirmed' do
      order = described_class.new(shop: shop, branch: branch, user: user)
      order.state = 'pending'
      expect(order.may_confirm?).to be true
    end

    it 'transitions from confirmed to completed' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'confirmed')
      expect(order.may_complete?).to be true
    end

    it 'transitions from pending to canceled' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'pending')
      expect(order.may_cancel?).to be true
    end

    it 'transitions from confirmed to canceled' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'confirmed')
      expect(order.may_cancel?).to be true
    end

    it 'cannot cancel a completed order' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'completed')
      expect(order.may_cancel?).to be false
    end

    it 'transitions from completed to refunding' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'completed')
      expect(order.may_init_refund?).to be true
    end

    it 'transitions from refunding to refunded' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'refunding')
      expect(order.may_complete_refund?).to be true
    end

    it 'transitions from refunding back to completed (cancel refund)' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'refunding')
      expect(order.may_cancel_refund?).to be true
    end
  end

  describe '#active?' do
    it 'returns true for pending orders' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'pending')
      expect(order.active?).to be true
    end

    it 'returns true for confirmed orders' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'confirmed')
      expect(order.active?).to be true
    end

    it 'returns false for completed orders' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'completed')
      expect(order.active?).to be false
    end

    it 'returns false for canceled orders' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'canceled')
      expect(order.active?).to be false
    end
  end

  describe '#can_user_cancel?' do
    it 'returns true for pending orders' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'pending')
      expect(order.can_user_cancel?).to be true
    end

    it 'returns false for confirmed orders' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'confirmed')
      expect(order.can_user_cancel?).to be false
    end
  end

  describe '#allow_actions' do
    it 'allows confirm and cancel in pending state' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'pending')
      expect(order.allow_actions).to contain_exactly(:confirm, :cancel)
    end

    it 'allows complete and cancel in confirmed state' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'confirmed')
      expect(order.allow_actions).to contain_exactly(:complete, :cancel)
    end

    it 'allows no actions in completed state' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'completed')
      expect(order.allow_actions).to be_empty
    end
  end

  describe 'acts_as_type :state' do
    it 'provides state query methods' do
      order = described_class.new(shop: shop, branch: branch, user: user, state: 'pending')
      expect(order.is_pending?).to be true
      expect(order.is_confirmed?).to be false
    end
  end

  describe '#is_first_order_of_user?' do
    it 'returns true when user has placed_orders_count == 1' do
      user = create(:user, shop: shop, placed_orders_count: 1)
      order = described_class.new(shop: shop, branch: branch, user: user)
      expect(order.is_first_order_of_user?).to be true
    end

    it 'returns false when user has placed_orders_count > 1' do
      user = create(:user, shop: shop, placed_orders_count: 5)
      order = described_class.new(shop: shop, branch: branch, user: user)
      expect(order.is_first_order_of_user?).to be false
    end
  end

  describe 'factory' do
    it 'creates a valid delivery order' do
      order = create(:order, shop: shop, branch: branch, user: user)
      expect(order).to be_persisted
      expect(order.state).to eq('pending')
    end

    it 'sets default totals' do
      order = create(:order, shop: shop, branch: branch, user: user)
      expect(order.item_total.to_f).to eq(50.0)
      expect(order.total.to_f).to eq(50.0)
    end
  end
end
