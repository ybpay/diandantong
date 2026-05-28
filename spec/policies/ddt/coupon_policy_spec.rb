# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::CouponPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :coupon, :show
  end

  describe '#apply?' do
    it_behaves_like 'an ApplicationPolicy permission', :coupon, :apply
  end

  describe '#exchange?' do
    it_behaves_like 'an ApplicationPolicy permission', :coupon, :exchange
  end
end
