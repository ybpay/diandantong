# frozen_string_literal: true

module Ddt
  class ComboImagePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:combo_image, :show)
    end

    def create?
      permission_allowed?(:combo_image, :create)
    end

    def update?
      permission_allowed?(:combo_image, :update)
    end

    def destroy?
      permission_allowed?(:combo_image, :destroy)
    end

  end
end
