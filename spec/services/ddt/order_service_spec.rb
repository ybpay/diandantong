# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::OrderService::CreateOrder, type: :service do
  let(:shop) { create(:shop_with_boss) }
  let(:branch) { shop.branches.first }
  let(:user) { create(:user, shop: shop) }

  describe '#call' do
    it 'creates an order with line items' do
      product = create(:product, shop: shop, branch: branch)
      variant = product.variants.first

      items = [{ variant_id: variant.id, quantity: 2, price: variant.price }]

      order = described_class.new(
        shop: shop,
        branch: branch,
        user: user,
        order_type: :delivery,
        items: items
      ).call

      expect(order).to be_persisted
      expect(order.line_items.count).to eq(1)
      expect(order.line_items.first.quantity).to eq(2)
    end

    it 'calculates totals correctly' do
      product = create(:product, shop: shop, branch: branch, price: 30.0)
      variant = product.variants.first

      items = [{ variant_id: variant.id, quantity: 3, price: 30.0 }]

      order = described_class.new(
        shop: shop,
        branch: branch,
        user: user,
        order_type: :delivery,
        items: items
      ).call

      expect(order.item_total.to_f).to eq(90.0)
    end

    it 'raises for unknown order type' do
      expect {
        described_class.new(
          shop: shop,
          branch: branch,
          user: user,
          order_type: :unknown,
          items: []
        ).call
      }.to raise_error(ArgumentError, /Unknown order type/)
    end
  end
end

RSpec.describe Ddt::OrderService::CancelOrder, type: :service do
  let(:shop) { create(:shop_with_boss) }
  let(:order) { create(:order, shop: shop, branch: shop.branches.first, user: create(:user, shop: shop)) }

  describe '#call' do
    it 'cancels the order' do
      cancelled = described_class.new(
        order,
        cancelled_by: shop.accounts.first
      ).call

      expect(cancelled.state).to eq('cancelled')
    end
  end
end
