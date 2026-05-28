# frozen_string_literal: true

module Ddt
  class CreditsSettingPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:credits_setting, :show)
    end

    def update?
      permission_allowed?(:credits_setting, :update)
    end

  end
end
