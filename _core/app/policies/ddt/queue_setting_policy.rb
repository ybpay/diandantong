# frozen_string_literal: true

module Ddt
  class QueueSettingPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:queue_setting, :show)
    end

    def create?
      permission_allowed?(:queue_setting, :create)
    end

    def update?
      permission_allowed?(:queue_setting, :update)
    end

    def destroy?
      permission_allowed?(:queue_setting, :destroy)
    end

  end
end
