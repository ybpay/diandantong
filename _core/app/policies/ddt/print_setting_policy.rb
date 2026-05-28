# frozen_string_literal: true

module Ddt
  class PrintSettingPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:print_setting, :show)
    end

    def update?
      permission_allowed?(:print_setting, :update)
    end

  end
end
