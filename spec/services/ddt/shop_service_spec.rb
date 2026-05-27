# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::ShopService, type: :service do
  describe '.active_branches' do
    let(:shop) { create(:shop) }

    it 'returns branches open on today' do
      branches = described_class.active_branches(shop)
      expect(branches).to be_a(ActiveRecord::Relation)
    end
  end

  describe '.expired?' do
    it 'returns true for expired shop' do
      shop = build(:shop, expiration_time: 1.day.ago)
      expect(described_class.expired?(shop)).to be true
    end

    it 'returns false for active shop' do
      shop = build(:shop, expiration_time: 1.year.from_now)
      expect(described_class.expired?(shop)).to be false
    end
  end

  describe '.in_recharge_time_range?' do
    it 'returns true when within one month of expiration' do
      shop = build(:shop, expiration_time: 2.weeks.from_now)
      expect(described_class.in_recharge_time_range?(shop)).to be true
    end

    it 'returns false when far from expiration' do
      shop = build(:shop, expiration_time: 6.months.from_now)
      expect(described_class.in_recharge_time_range?(shop)).to be false
    end
  end

  describe '.shop_json' do
    it 'returns formatted shop data' do
      shop = build(:shop, id: 1, name: '测试', slug: 'abc123')
      result = described_class.shop_json(shop)
      expect(result).to eq({ id: 1, name: 'abc123-测试' })
    end
  end

  describe '.branches_select_json' do
    let(:shop) { create(:shop) }

    it 'returns branch selection data' do
      result = described_class.branches_select_json(
        shop,
        range_branches: shop.branches,
        all_branch_ids: nil
      )
      expect(result).to be_an(Array)
      expect(result.length).to be > 0
    end
  end
end
