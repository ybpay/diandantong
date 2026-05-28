# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::BillCenterPolicy do

  describe '#discount_list?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_center, :discount_list
  end

  describe '#waiter_list?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_center, :waiter_list
  end

  describe '#gift_item_list?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_center, :gift_item_list
  end

  describe '#subtract_item_list?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_center, :subtract_item_list
  end

  describe '#sale_list?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_center, :sale_list
  end

  describe '#payment_list?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_center, :payment_list
  end

  describe '#shift_list?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_center, :shift_list
  end

  describe '#combo_package_list?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_center, :combo_package_list
  end

  describe '#order_cancel_list?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_center, :order_cancel_list
  end

  describe '#anti_settlement_list?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_center, :anti_settlement_list
  end

  describe '#queue_list?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_center, :queue_list
  end

  describe '#by_weight_product_list?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_center, :by_weight_product_list
  end
end
