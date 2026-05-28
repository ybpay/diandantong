# frozen_string_literal: true

module Ddt
  class FormElementPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:form_element, :show)
    end

    def create?
      permission_allowed?(:form_element, :create)
    end

    def update?
      permission_allowed?(:form_element, :update)
    end

    def destroy?
      permission_allowed?(:form_element, :destroy)
    end

  end
end
