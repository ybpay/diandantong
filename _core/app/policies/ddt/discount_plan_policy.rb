# frozen_string_literal: true

module Ddt
  class DiscountPlanPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:discount_plan, :show)
    end

    def create?
      permission_allowed?(:discount_plan, :create)
    end

    def update?
      permission_allowed?(:discount_plan, :update)
    end

    def destroy?
      permission_allowed?(:discount_plan, :destroy)
    end

  end
end
