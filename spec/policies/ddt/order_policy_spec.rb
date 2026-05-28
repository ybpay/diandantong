# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::OrderPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :show
  end

  describe '#confirm?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :confirm
  end

  describe '#complete?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :complete
  end

  describe '#cancel?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :cancel
  end

  describe '#reprint?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :reprint
  end

  describe '#settle?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :settle
  end

  describe '#anti_settlement?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :anti_settlement
  end

  describe '#append_pay_item?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :append_pay_item
  end

  describe '#append?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :append
  end

  describe '#gift_item?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :gift_item
  end

  describe '#subtract?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :subtract
  end

  describe '#hasten?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :hasten
  end

  describe '#change_vip_info?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :change_vip_info
  end

  describe '#privilege_discount?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :privilege_discount
  end

  describe '#cancel_privilege_discount?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :cancel_privilege_discount
  end

  describe '#change_item_price?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :change_item_price
  end

  describe '#batch_change_state?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :batch_change_state
  end

  describe '#add_discount_plan?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :add_discount_plan
  end

  describe '#cancel_discount_plan?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :cancel_discount_plan
  end

  describe '#add_disabled_promotion?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :add_disabled_promotion
  end

  describe '#remove_disabled_promotion?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :remove_disabled_promotion
  end

  describe '#refund?' do
    it_behaves_like 'an ApplicationPolicy permission', :order, :refund
  end
end
