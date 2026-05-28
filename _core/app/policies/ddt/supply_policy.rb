# frozen_string_literal: true

module Ddt
  class SupplyPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:supply, :show)
    end

  end
end
