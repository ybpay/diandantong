# frozen_string_literal: true

module Ddt
  class AccountPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:account, :show)
    end

    def create?
      permission_allowed?(:account, :create)
    end

    def update?
      permission_allowed?(:account, :update)
    end

    def destroy?
      permission_allowed?(:account, :destroy)
    end
  end
end
