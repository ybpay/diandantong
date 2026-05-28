# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Coupon, type: :model do
  let(:shop) { create(:shop_with_boss) }
  let(:user) { create(:user, shop: shop) }
  let(:coupon_version) { create(:coupon_version, shop: shop) }

  describe 'associations' do
    it { should belong_to(:coupon_version).class_name('Ddt::CouponVersion') }
  end

  describe 'inheritance' do
    it 'inherits from Ddt::BaseCoupon' do
      expect(described_class.ancestors).to include(Ddt::BaseCoupon)
    end

    it 'sets STI type to Ddt::Coupon' do
      coupon = create(:coupon, shop: shop, base_user: user, coupon_version: coupon_version)
      expect(coupon.type).to eq('Ddt::Coupon')
    end
  end

  describe '#usable?' do
    it 'returns true when not expired and not applied' do
      coupon = create(:coupon, shop: shop, base_user: user, coupon_version: coupon_version)
      expect(coupon.usable?).to be true
    end

    it 'returns false when expired' do
      coupon = create(:coupon, shop: shop, base_user: user, coupon_version: coupon_version,
                                expires_at: 1.day.ago)
      expect(coupon.usable?).to be false
    end
  end

  describe '#expired?' do
    it 'returns true when expires_at is past' do
      coupon = create(:coupon, shop: shop, base_user: user, coupon_version: coupon_version,
                                expires_at: 1.day.ago)
      expect(coupon.expired?).to be true
    end

    it 'returns false when expires_at is future' do
      coupon = create(:coupon, shop: shop, base_user: user, coupon_version: coupon_version,
                                expires_at: 1.year.from_now)
      expect(coupon.expired?).to be false
    end
  end

  describe '#applied?' do
    it 'returns false when not applied' do
      coupon = create(:coupon, shop: shop, base_user: user, coupon_version: coupon_version)
      expect(coupon.applied?).to be false
    end

    it 'returns true when applied_at is set' do
      coupon = create(:coupon, shop: shop, base_user: user, coupon_version: coupon_version,
                                applied_at: Time.current)
      expect(coupon.applied?).to be true
    end
  end

  describe 'factory' do
    it 'creates a valid coupon' do
      coupon = create(:coupon, shop: shop, base_user: user, coupon_version: coupon_version)
      expect(coupon).to be_persisted
      expect(coupon.coupon_no).to be_present
    end
  end
end

RSpec.describe Ddt::Voucher, type: :model do
  let(:shop) { create(:shop_with_boss) }
  let(:user) { create(:user, shop: shop) }
  let(:voucher_version) { create(:voucher_version, shop: shop) }

  describe 'associations' do
    it { should belong_to(:voucher_version).class_name('Ddt::VoucherVersion') }
  end

  describe 'inheritance' do
    it 'inherits from Ddt::BaseCoupon' do
      expect(described_class.ancestors).to include(Ddt::BaseCoupon)
    end

    it 'sets STI type to Ddt::Voucher' do
      voucher = create(:voucher, shop: shop, base_user: user, voucher_version: voucher_version)
      expect(voucher.type).to eq('Ddt::Voucher')
    end
  end

  describe '#usable?' do
    it 'returns true when not expired and not applied' do
      voucher = create(:voucher, shop: shop, base_user: user, voucher_version: voucher_version)
      expect(voucher.usable?).to be true
    end
  end

  describe '#expired?' do
    it 'returns true when expires_at is past' do
      voucher = create(:voucher, shop: shop, base_user: user, voucher_version: voucher_version,
                                  expires_at: 1.day.ago)
      expect(voucher.expired?).to be true
    end
  end

  describe 'factory' do
    it 'creates a valid voucher' do
      voucher = create(:voucher, shop: shop, base_user: user, voucher_version: voucher_version)
      expect(voucher).to be_persisted
      expect(voucher.coupon_no).to be_present
    end
  end
end

RSpec.describe Ddt::Groupon, type: :model do
  let(:shop) { create(:shop_with_boss) }
  let(:user) { create(:user, shop: shop) }
  let(:groupon_version) { create(:groupon_version, shop: shop) }

  describe 'associations' do
    it { should belong_to(:groupon_version).class_name('Ddt::GrouponVersion') }
  end

  describe 'inheritance' do
    it 'inherits from Ddt::BaseCoupon' do
      expect(described_class.ancestors).to include(Ddt::BaseCoupon)
    end

    it 'sets STI type to Ddt::Groupon' do
      groupon = create(:groupon, shop: shop, base_user: user, groupon_version: groupon_version)
      expect(groupon.type).to eq('Ddt::Groupon')
    end
  end

  describe '#usable?' do
    it 'returns true when not expired and not applied' do
      groupon = create(:groupon, shop: shop, base_user: user, groupon_version: groupon_version)
      expect(groupon.usable?).to be true
    end
  end

  describe '#expired?' do
    it 'returns true when expires_at is past' do
      groupon = create(:groupon, shop: shop, base_user: user, groupon_version: groupon_version,
                                  expires_at: 1.day.ago)
      expect(groupon.expired?).to be true
    end
  end

  describe 'factory' do
    it 'creates a valid groupon' do
      groupon = create(:groupon, shop: shop, base_user: user, groupon_version: groupon_version)
      expect(groupon).to be_persisted
      expect(groupon.coupon_no).to be_present
    end
  end
end
