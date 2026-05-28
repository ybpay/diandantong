# frozen_string_literal: true

module Ddt
  class DeliverySettingPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:delivery_setting, :show)
    end

    def update?
      permission_allowed?(:delivery_setting, :update)
    end

  end
end
