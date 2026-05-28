# frozen_string_literal: true

module Ddt
  class PayMethodPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:pay_method, :show)
    end

    def create?
      permission_allowed?(:pay_method, :create)
    end

    def update?
      permission_allowed?(:pay_method, :update)
    end

    def destroy?
      permission_allowed?(:pay_method, :destroy)
    end

  end
end
