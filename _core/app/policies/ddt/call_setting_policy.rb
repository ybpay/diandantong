# frozen_string_literal: true

module Ddt
  class CallSettingPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:call_setting, :show)
    end

    def update?
      permission_allowed?(:call_setting, :update)
    end

  end
end
