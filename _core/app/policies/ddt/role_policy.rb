# frozen_string_literal: true

module Ddt
  class RolePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:role, :show)
    end

    def create?
      permission_allowed?(:role, :create)
    end

    def update?
      permission_allowed?(:role, :update)
    end

    def destroy?
      permission_allowed?(:role, :destroy)
    end
  end
end
