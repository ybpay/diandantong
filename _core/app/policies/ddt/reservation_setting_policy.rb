# frozen_string_literal: true

module Ddt
  class ReservationSettingPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:reservation_setting, :show)
    end

    def update?
      permission_allowed?(:reservation_setting, :update)
    end

  end
end
