# frozen_string_literal: true

module Ddt
  class PrinterCodePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:printer_code, :show)
    end

    def create?
      permission_allowed?(:printer_code, :create)
    end

    def update?
      permission_allowed?(:printer_code, :update)
    end

    def destroy?
      permission_allowed?(:printer_code, :destroy)
    end

  end
end
