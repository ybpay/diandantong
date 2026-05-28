# frozen_string_literal: true

module Ddt
  class OrderPromotionPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:order_promotion, :show)
    end

    def create?
      permission_allowed?(:order_promotion, :create)
    end

    def update?
      permission_allowed?(:order_promotion, :update)
    end

    def destroy?
      permission_allowed?(:order_promotion, :destroy)
    end

  end
end
