# frozen_string_literal: true

module Ddt
  class PaymentMethodPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:payment_method, :show)
    end

    def update?
      permission_allowed?(:payment_method, :update)
    end

  end
end
