# frozen_string_literal: true

module Ddt
  class VariantImagePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:variant_image, :show)
    end

    def create?
      permission_allowed?(:variant_image, :create)
    end

    def update?
      permission_allowed?(:variant_image, :update)
    end

    def destroy?
      permission_allowed?(:variant_image, :destroy)
    end

  end
end
