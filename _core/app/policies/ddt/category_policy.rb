# frozen_string_literal: true

module Ddt
  class CategoryPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:category, :show)
    end

    def create?
      permission_allowed?(:category, :create)
    end

    def update?
      permission_allowed?(:category, :update)
    end

    def destroy?
      permission_allowed?(:category, :destroy)
    end

  end
end
