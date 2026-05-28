# frozen_string_literal: true

module Ddt
  class PaymentPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:payment, :show)
    end

  end
end
