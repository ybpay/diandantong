# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Shop, type: :model do
  describe 'associations' do
    it { should have_many(:branches).dependent(:destroy) }
    it { should have_many(:accounts).dependent(:destroy) }
    it { should have_many(:users).dependent(:destroy) }
    it { should have_many(:orders) }
    it { should have_many(:payments).dependent(:destroy) }
    it { should have_many(:products).through(:branches) }
    it { should have_many(:promotions) }
    it { should have_one(:credits_wallet) }
    it { should have_one(:card_wallet) }
    it { should have_one(:short_message_setting) }
    it { should have_many(:vip_levels) }
    it { should have_many(:wechat_accounts).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:telephone) }
    it { should validate_uniqueness_of(:telephone) }
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug) }
  end

  describe 'default scope' do
    it 'orders by created_at desc' do
      shop_old = create(:shop)
      shop_new = create(:shop)
      expect(Ddt::Shop.all.to_a).to eq([shop_new, shop_old])
    end
  end

  describe '#expired?' do
    it 'returns true when expiration_time is in the past' do
      shop = build(:shop, expiration_time: 1.day.ago)
      expect(shop.expired?).to be true
    end

    it 'returns false when expiration_time is in the future' do
      shop = build(:shop, expiration_time: 1.year.from_now)
      expect(shop.expired?).to be false
    end
  end

  describe '#is_multi_branches?' do
    it 'returns true when max_branches_limit > 1' do
      shop = build(:shop, max_branches_limit: 5)
      expect(shop.is_multi_branches?).to be true
    end

    it 'returns false when max_branches_limit == 1' do
      shop = build(:shop, max_branches_limit: 1)
      expect(shop.is_multi_branches?).to be false
    end
  end

  describe '#support_brand_name' do
    it 'returns site brand name by default' do
      shop = build(:shop)
      expect(shop.support_brand_name).to eq(Ddt::SiteConfig.brand_name)
    end

    it 'returns custom brand name when use_custom_brand is set' do
      shop = build(:shop, use_custom_brand: true, custom_brand_name: 'My Brand')
      expect(shop.support_brand_name).to eq('My Brand')
    end
  end

  describe '#currency' do
    it 'returns default currency symbol' do
      shop = build(:shop, enable_foreign: false)
      expect(shop.currency).to eq('￥')
    end

    it 'returns foreign currency symbol when enabled' do
      shop = build(:shop, enable_foreign: true, foreign_currency_symbol: '$')
      expect(shop.currency).to eq('$')
    end
  end

  describe '#active_branches' do
    it 'returns branches that are open on today' do
      shop = create(:shop)
      expect(shop.active_branches).to be_a(ActiveRecord::Relation)
    end
  end

  describe '#has_module?' do
    let(:shop) { create(:shop) }

    it 'returns false for unconfigured modules' do
      expect(shop.has_module?(:nonexistent)).to be false
    end
  end

  describe 'factory' do
    it 'creates a valid shop' do
      shop = create(:shop)
      expect(shop).to be_persisted
      expect(shop.name).to be_present
      expect(shop.slug).to be_present
    end

    it 'creates a shop with boss account' do
      shop = create(:shop_with_boss)
      expect(shop.accounts.count).to be >= 1
      boss = shop.accounts.first
      expect(boss.is_boss?).to be true
    end

    it 'creates an expired shop with trait' do
      shop = create(:shop, :expired)
      expect(shop.expired?).to be true
    end

    it 'creates a multi-branch shop with trait' do
      shop = create(:shop, :multi_branch)
      expect(shop.is_multi_branches?).to be true
    end
  end

  describe 'after_create callbacks' do
    it 'automatically creates a branch' do
      shop = create(:shop)
      expect(shop.branches.real.count).to be >= 1
    end

    it 'automatically creates a short_message_setting' do
      shop = create(:shop)
      expect(shop.short_message_setting).to be_present
    end
  end
end
