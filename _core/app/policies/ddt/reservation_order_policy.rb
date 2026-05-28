# frozen_string_literal: true

module Ddt
  class ReservationOrderPolicy < ApplicationPolicy
    def create?
      permission_allowed?(:reservation_order, :create)
    end

    def change_to_eat_in_hall?
      permission_allowed?(:reservation_order, :change_to_eat_in_hall)
    end

    def bind_table?
      permission_allowed?(:reservation_order, :bind_table)
    end

    def edit_reservation_info?
      permission_allowed?(:reservation_order, :edit_reservation_info)
    end
  end
end
