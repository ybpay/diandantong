# frozen_string_literal: true

module Ddt
  class CouponVersionPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:coupon_version, :show)
    end

    def create?
      permission_allowed?(:coupon_version, :create)
    end

    def update?
      permission_allowed?(:coupon_version, :update)
    end

    def destroy?
      permission_allowed?(:coupon_version, :destroy)
    end

    def send_coupon?
      permission_allowed?(:coupon_version, :send_coupon)
    end

  end
end
