# frozen_string_literal: true

module Ddt
  class TickAccountPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:tick_account, :show)
    end

    def create?
      permission_allowed?(:tick_account, :create)
    end

    def update?
      permission_allowed?(:tick_account, :update)
    end

    def destroy?
      permission_allowed?(:tick_account, :destroy)
    end

  end
end
