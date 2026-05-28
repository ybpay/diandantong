# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::RechargeOrderPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :recharge_order, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :recharge_order, :create
  end

  describe '#reprint?' do
    it_behaves_like 'an ApplicationPolicy permission', :recharge_order, :reprint
  end

  describe '#settle?' do
    it_behaves_like 'an ApplicationPolicy permission', :recharge_order, :settle
  end

  describe '#cancel?' do
    it_behaves_like 'an ApplicationPolicy permission', :recharge_order, :cancel
  end

  describe '#init_refund?' do
    it_behaves_like 'an ApplicationPolicy permission', :recharge_order, :init_refund
  end
end
