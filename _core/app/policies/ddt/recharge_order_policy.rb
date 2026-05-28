# frozen_string_literal: true

module Ddt
  class RechargeOrderPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:recharge_order, :show)
    end

    def create?
      permission_allowed?(:recharge_order, :create)
    end

    def reprint?
      permission_allowed?(:recharge_order, :reprint)
    end

    def settle?
      permission_allowed?(:recharge_order, :settle)
    end

    def cancel?
      permission_allowed?(:recharge_order, :cancel)
    end

    def init_refund?
      permission_allowed?(:recharge_order, :init_refund)
    end
  end
end
