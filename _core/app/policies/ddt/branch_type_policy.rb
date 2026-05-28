# frozen_string_literal: true

module Ddt
  class BranchTypePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:branch_type, :show)
    end

    def create?
      permission_allowed?(:branch_type, :create)
    end

    def update?
      permission_allowed?(:branch_type, :update)
    end

    def destroy?
      permission_allowed?(:branch_type, :destroy)
    end

  end
end
