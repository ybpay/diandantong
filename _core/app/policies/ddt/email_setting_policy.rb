# frozen_string_literal: true

module Ddt
  class EmailSettingPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:email_setting, :show)
    end

    def update?
      permission_allowed?(:email_setting, :update)
    end

  end
end
