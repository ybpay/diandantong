# frozen_string_literal: true

module Ddt
  class BranchGroupPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:branch_group, :show)
    end

    def create?
      permission_allowed?(:branch_group, :create)
    end

    def update?
      permission_allowed?(:branch_group, :update)
    end

    def destroy?
      permission_allowed?(:branch_group, :destroy)
    end

  end
end
