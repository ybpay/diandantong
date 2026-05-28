# frozen_string_literal: true

module Ddt
  class EssentialProductPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:essential_product, :show)
    end

    def create?
      permission_allowed?(:essential_product, :create)
    end

    def update?
      permission_allowed?(:essential_product, :update)
    end

    def destroy?
      permission_allowed?(:essential_product, :destroy)
    end

  end
end
