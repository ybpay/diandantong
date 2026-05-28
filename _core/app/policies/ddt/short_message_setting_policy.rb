# frozen_string_literal: true

module Ddt
  class ShortMessageSettingPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:short_message_setting, :show)
    end

    def update?
      permission_allowed?(:short_message_setting, :update)
    end

  end
end
