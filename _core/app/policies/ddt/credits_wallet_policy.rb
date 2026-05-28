# frozen_string_literal: true

module Ddt
  class CreditsWalletPolicy < ApplicationPolicy
    def manage?
      permission_allowed?(:credits_wallet, :manage)
    end

  end
end
