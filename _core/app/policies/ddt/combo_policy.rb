# frozen_string_literal: true

module Ddt
  class ComboPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:combo, :show)
    end

    def create?
      permission_allowed?(:combo, :create)
    end

    def update?
      permission_allowed?(:combo, :update)
    end

    def destroy?
      permission_allowed?(:combo, :destroy)
    end

  end
end
