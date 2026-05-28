# frozen_string_literal: true

module Ddt
  class FastfoodOrderPolicy < ApplicationPolicy
    def create?
      permission_allowed?(:fastfood_order, :create)
    end

    def call_customer?
      permission_allowed?(:fastfood_order, :call_customer)
    end

    def create_and_pay?
      permission_allowed?(:fastfood_order, :create_and_pay)
    end
  end
end
