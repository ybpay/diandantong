# frozen_string_literal: true

module Ddt
  class ArrangingSettingPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:arranging_setting, :show)
    end

    def update?
      permission_allowed?(:arranging_setting, :update)
    end

  end
end
