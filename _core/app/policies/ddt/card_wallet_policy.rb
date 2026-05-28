# frozen_string_literal: true

module Ddt
  class CardWalletPolicy < ApplicationPolicy
    def manage?
      permission_allowed?(:card_wallet, :manage)
    end

  end
end
