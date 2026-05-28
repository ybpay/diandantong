# frozen_string_literal: true

module Ddt
  class ProductPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:product, :show)
    end

    def create?
      permission_allowed?(:product, :create)
    end

    def update?
      permission_allowed?(:product, :update)
    end

    def destroy?
      permission_allowed?(:product, :destroy)
    end

    def estimate_clear?
      permission_allowed?(:product, :estimate_clear)
    end
  end
end
