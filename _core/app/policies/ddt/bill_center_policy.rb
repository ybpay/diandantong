# frozen_string_literal: true

module Ddt
  class BillCenterPolicy < ApplicationPolicy
    %i[discount_list waiter_list gift_item_list subtract_item_list sale_list
       payment_list shift_list combo_package_list order_cancel_list
       anti_settlement_list queue_list by_weight_product_list].each do |action|
      define_method :"#{action}?" do
        permission_allowed?(:bill_center, action)
      end
    end
  end
end
