# frozen_string_literal: true

module Ddt
  class PaymentOrderPolicy < ApplicationPolicy
    def create?
      permission_allowed?(:payment_order, :create)
    end
  end
end
