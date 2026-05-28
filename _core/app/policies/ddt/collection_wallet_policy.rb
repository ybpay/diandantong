# frozen_string_literal: true

module Ddt
  class CollectionWalletPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:collection_wallet, :show)
    end

    def withdraw?
      permission_allowed?(:collection_wallet, :withdraw)
    end

  end
end
