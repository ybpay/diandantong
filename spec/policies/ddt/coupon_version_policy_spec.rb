# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::CouponVersionPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :coupon_version, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :coupon_version, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :coupon_version, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :coupon_version, :destroy
  end

  describe '#send_coupon?' do
    it_behaves_like 'an ApplicationPolicy permission', :coupon_version, :send_coupon
  end
end
