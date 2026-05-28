# frozen_string_literal: true

module Ddt
  class CouponPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:coupon, :show)
    end

    def apply?
      permission_allowed?(:coupon, :apply)
    end

    def exchange?
      permission_allowed?(:coupon, :exchange)
    end
  end
end
