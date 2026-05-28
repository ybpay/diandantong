# frozen_string_literal: true

module Ddt
  class ZonePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:zone, :show)
    end

    def create?
      permission_allowed?(:zone, :create)
    end

    def update?
      permission_allowed?(:zone, :update)
    end

    def destroy?
      permission_allowed?(:zone, :destroy)
    end

  end
end
