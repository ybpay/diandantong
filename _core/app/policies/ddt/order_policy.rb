# frozen_string_literal: true

module Ddt
  class OrderPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:order, :show)
    end

    def confirm?
      permission_allowed?(:order, :confirm)
    end

    def complete?
      permission_allowed?(:order, :complete)
    end

    def cancel?
      permission_allowed?(:order, :cancel)
    end

    def reprint?
      permission_allowed?(:order, :reprint)
    end

    def settle?
      permission_allowed?(:order, :settle)
    end

    def anti_settlement?
      permission_allowed?(:order, :anti_settlement)
    end

    def append_pay_item?
      permission_allowed?(:order, :append_pay_item)
    end

    def append?
      permission_allowed?(:order, :append)
    end

    def gift_item?
      permission_allowed?(:order, :gift_item)
    end

    def subtract?
      permission_allowed?(:order, :subtract)
    end

    def hasten?
      permission_allowed?(:order, :hasten)
    end

    def change_vip_info?
      permission_allowed?(:order, :change_vip_info)
    end

    def privilege_discount?
      permission_allowed?(:order, :privilege_discount)
    end

    def cancel_privilege_discount?
      permission_allowed?(:order, :cancel_privilege_discount)
    end

    def change_item_price?
      permission_allowed?(:order, :change_item_price)
    end

    def batch_change_state?
      permission_allowed?(:order, :batch_change_state)
    end

    def add_discount_plan?
      permission_allowed?(:order, :add_discount_plan)
    end

    def cancel_discount_plan?
      permission_allowed?(:order, :cancel_discount_plan)
    end

    def add_disabled_promotion?
      permission_allowed?(:order, :add_disabled_promotion)
    end

    def remove_disabled_promotion?
      permission_allowed?(:order, :remove_disabled_promotion)
    end

    def refund?
      permission_allowed?(:order, :refund)
    end
  end
end
