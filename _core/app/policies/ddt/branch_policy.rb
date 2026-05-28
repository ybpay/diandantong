# frozen_string_literal: true

module Ddt
  class BranchPolicy < ApplicationPolicy
    # Shop-scope actions
    def show?
      permission_allowed?(:branch, :show)
    end

    def create?
      permission_allowed?(:branch, :create)
    end

    def update?
      permission_allowed?(:branch, :update)
    end

    def destroy?
      permission_allowed?(:branch, :destroy)
    end

    def clear_data?
      permission_allowed?(:branch, :clear_data)
    end

    # Branch-scope actions
    def open_shift?
      permission_allowed?(:branch, :open_shift)
    end

    def close_shift?
      permission_allowed?(:branch, :close_shift)
    end
  end
end
