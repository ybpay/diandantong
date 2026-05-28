# frozen_string_literal: true

module Ddt
  class PrinterPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:printer, :show)
    end

    def create?
      permission_allowed?(:printer, :create)
    end

    def update?
      permission_allowed?(:printer, :update)
    end

    def destroy?
      permission_allowed?(:printer, :destroy)
    end

  end
end
