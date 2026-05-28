# frozen_string_literal: true

module Ddt
  class PaymentLogPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:payment_log, :show)
    end

  end
end
