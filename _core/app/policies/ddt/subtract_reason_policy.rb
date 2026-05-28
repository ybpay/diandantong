# frozen_string_literal: true

module Ddt
  class SubtractReasonPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:subtract_reason, :show)
    end

    def create?
      permission_allowed?(:subtract_reason, :create)
    end

    def update?
      permission_allowed?(:subtract_reason, :update)
    end

    def destroy?
      permission_allowed?(:subtract_reason, :destroy)
    end

  end
end
