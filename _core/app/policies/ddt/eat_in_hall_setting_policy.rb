# frozen_string_literal: true

module Ddt
  class EatInHallSettingPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:eat_in_hall_setting, :show)
    end

    def update?
      permission_allowed?(:eat_in_hall_setting, :update)
    end

  end
end
