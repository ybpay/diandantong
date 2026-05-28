# frozen_string_literal: true

module Ddt
  class GrouponVersionPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:groupon_version, :show)
    end

    def create?
      permission_allowed?(:groupon_version, :create)
    end

    def update?
      permission_allowed?(:groupon_version, :update)
    end

    def destroy?
      permission_allowed?(:groupon_version, :destroy)
    end

  end
end
