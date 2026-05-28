# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::VipLevel, type: :model do
  let(:shop) { create(:shop_with_boss) }

  describe 'associations' do
    it { should belong_to(:shop) }
    it { should have_many(:vip_infos) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:level).is_greater_than(0) }
    it { should validate_numericality_of(:discount).is_greater_than(0).is_less_than_or_equal_to(1.0) }
  end

  describe 'uniqueness validation' do
    it 'validates name uniqueness scoped to shop_id and discarded_at' do
      create(:vip_level, shop: shop, name: '黄金会员')
      duplicate = build(:vip_level, shop: shop, name: '黄金会员')
      expect(duplicate).not_to be_valid
    end

    it 'allows same name in different shops' do
      other_shop = create(:shop)
      create(:vip_level, shop: shop, name: '黄金会员')
      level = build(:vip_level, shop: other_shop, name: '黄金会员')
      expect(level).to be_valid
    end
  end

  describe 'default scope' do
    it 'orders by discount desc then is_default desc' do
      level3 = create(:vip_level, shop: shop, discount: 0.8, is_default: false)
      level1 = create(:vip_level, shop: shop, discount: 0.95, is_default: true)
      level2 = create(:vip_level, shop: shop, discount: 0.9, is_default: false)
      expect(shop.vip_levels.pluck(:id)).to eq([level3, level2, level1].map(&:id))
    end
  end

  describe '.default_level' do
    it 'returns the default vip level' do
      default = create(:vip_level, shop: shop, :default)
      expect(described_class.default_level).to eq(default)
    end
  end

  describe '#vip_infos_count' do
    it 'returns the cached counter cache value' do
      level = create(:vip_level, shop: shop)
      expect(level.vip_infos_count).to eq(0)
    end
  end

  describe 'Discard::Model' do
    it 'soft deletes a vip level' do
      level = create(:vip_level, shop: shop)
      level.discard!
      expect(level.discarded?).to be true
      expect(described_class.with_discarded).to include(level)
    end
  end

  describe 'factory' do
    it 'creates a valid vip level' do
      level = create(:vip_level, shop: shop)
      expect(level).to be_persisted
      expect(level.name).to be_present
      expect(level.discount).to be <= 1.0
    end

    it 'creates a default vip level with trait' do
      level = create(:vip_level, shop: shop, :default)
      expect(level.is_default).to be true
      expect(level.discount).to eq(1.0)
    end
  end
end

RSpec.describe Ddt::VipInfo, type: :model do
  let(:shop) { create(:shop_with_boss) }

  describe 'associations' do
    it { should belong_to(:vip_level) }
    it { should have_many(:base_users) }
  end

  describe 'validations' do
    it { should validate_presence_of(:placed_orders_count) }
    it { should validate_presence_of(:total_amount) }
  end

  describe '#is_vip?' do
    it 'returns true when vip_info is present' do
      vip_info = create(:vip_info, shop: shop)
      expect(vip_info.is_vip?).to be true
    end
  end

  describe 'factory' do
    it 'creates a valid vip info' do
      user = create(:user, shop: shop)
      vip_info = create(:vip_info, shop: shop, user: user)
      expect(vip_info).to be_persisted
      expect(vip_info.phone).to be_present
    end
  end
end
