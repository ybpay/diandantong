# frozen_string_literal: true

module Ddt
  class RechargeProductPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:recharge_product, :show)
    end

    def create?
      permission_allowed?(:recharge_product, :create)
    end

    def update?
      permission_allowed?(:recharge_product, :update)
    end

    def destroy?
      permission_allowed?(:recharge_product, :destroy)
    end

  end
end
