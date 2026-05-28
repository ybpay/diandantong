# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::RechargeRefundPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :recharge_refund, :show
  end

  describe '#complete?' do
    it_behaves_like 'an ApplicationPolicy permission', :recharge_refund, :complete
  end

  describe '#cancel?' do
    it_behaves_like 'an ApplicationPolicy permission', :recharge_refund, :cancel
  end
end
