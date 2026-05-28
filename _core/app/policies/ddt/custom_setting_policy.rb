# frozen_string_literal: true

module Ddt
  class CustomSettingPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:custom_setting, :show)
    end

    def update?
      permission_allowed?(:custom_setting, :update)
    end

  end
end
