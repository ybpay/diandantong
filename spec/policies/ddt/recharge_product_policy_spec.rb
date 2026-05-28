# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::RechargeProductPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :recharge_product, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :recharge_product, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :recharge_product, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :recharge_product, :destroy
  end
end
