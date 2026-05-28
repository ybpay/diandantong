# frozen_string_literal: true

module Ddt
  class OptionTypePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:option_type, :show)
    end

    def create?
      permission_allowed?(:option_type, :create)
    end

    def update?
      permission_allowed?(:option_type, :update)
    end

    def destroy?
      permission_allowed?(:option_type, :destroy)
    end

  end
end
