# frozen_string_literal: true

module Ddt
  class RechargeRefundPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:recharge_refund, :show)
    end

    def complete?
      permission_allowed?(:recharge_refund, :complete)
    end

    def cancel?
      permission_allowed?(:recharge_refund, :cancel)
    end

  end
end
