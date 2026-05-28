# frozen_string_literal: true

module Ddt
  class UserPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:user, :show)
    end

    def update?
      permission_allowed?(:user, :update)
    end

    def recharge_card_wallet?
      permission_allowed?(:user, :recharge_card_wallet)
    end

    def exchange_card_wallet?
      permission_allowed?(:user, :exchange_card_wallet)
    end

    def exchange_credits_wallet?
      permission_allowed?(:user, :exchange_credits_wallet)
    end

    def get_credits_wallet?
      permission_allowed?(:user, :get_credits_wallet)
    end

    def send_coupon?
      permission_allowed?(:user, :send_coupon)
    end

    def create?
      permission_allowed?(:user, :create)
    end

    def destroy?
      permission_allowed?(:user, :destroy)
    end
  end
end
