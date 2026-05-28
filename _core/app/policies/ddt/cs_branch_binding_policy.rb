# frozen_string_literal: true

module Ddt
  class CsBranchBindingPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:cs_branch_binding, :show)
    end

    def update?
      permission_allowed?(:cs_branch_binding, :update)
    end

  end
end
