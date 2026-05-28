# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::GrouponOrderPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :groupon_order, :show
  end

  describe '#confirm?' do
    it_behaves_like 'an ApplicationPolicy permission', :groupon_order, :confirm
  end

  describe '#complete?' do
    it_behaves_like 'an ApplicationPolicy permission', :groupon_order, :complete
  end

  describe '#cancel?' do
    it_behaves_like 'an ApplicationPolicy permission', :groupon_order, :cancel
  end

  describe '#reprint?' do
    it_behaves_like 'an ApplicationPolicy permission', :groupon_order, :reprint
  end

  describe '#settle?' do
    it_behaves_like 'an ApplicationPolicy permission', :groupon_order, :settle
  end

  describe '#append_pay_item?' do
    it_behaves_like 'an ApplicationPolicy permission', :groupon_order, :append_pay_item
  end
end
