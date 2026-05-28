# frozen_string_literal: true

module Ddt
  class EatInHallOrderPolicy < ApplicationPolicy
    def create?
      permission_allowed?(:eat_in_hall_order, :create)
    end

    def change_table?
      permission_allowed?(:eat_in_hall_order, :change_table)
    end

    def merge_table?
      permission_allowed?(:eat_in_hall_order, :merge_table)
    end

    def move_itemable?
      permission_allowed?(:eat_in_hall_order, :move_itemable)
    end

    def bind_reservation_order?
      permission_allowed?(:eat_in_hall_order, :bind_reservation_order)
    end

    def trace_waiter?
      permission_allowed?(:eat_in_hall_order, :trace_waiter)
    end

    def allow_selfpay?
      permission_allowed?(:eat_in_hall_order, :allow_selfpay)
    end

    def update_guest_num?
      permission_allowed?(:eat_in_hall_order, :update_guest_num)
    end

    def change_line_item_weight?
      permission_allowed?(:eat_in_hall_order, :change_line_item_weight)
    end
  end
end
