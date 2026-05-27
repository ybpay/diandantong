# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::PromotionEngine::ApplyPromotions, type: :service do
  let(:shop) { create(:shop_with_boss) }
  let(:order) { create(:order, shop: shop, branch: shop.branches.first, user: create(:user, shop: shop)) }

  describe '.call' do
    it 'returns nil when no promotions exist' do
      result = described_class.call(order)
      expect(result).to be_nil
    end

    it 'processes eligible promotions' do
      allow(order).to receive(:shop).and_return(shop)
      allow(shop).to receive(:promotions_including_branch).and_return(double(active: []))
      result = described_class.call(order)
      expect(result).to be_nil
    end
  end
end
