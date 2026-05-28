# frozen_string_literal: true

module Ddt
  class TagPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:tag, :show)
    end

    def update?
      permission_allowed?(:tag, :update)
    end

    def destroy?
      permission_allowed?(:tag, :destroy)
    end

  end
end
