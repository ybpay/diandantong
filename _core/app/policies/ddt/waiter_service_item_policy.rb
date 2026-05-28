# frozen_string_literal: true

module Ddt
  class WaiterServiceItemPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:waiter_service_item, :show)
    end

    def create?
      permission_allowed?(:waiter_service_item, :create)
    end

    def update?
      permission_allowed?(:waiter_service_item, :update)
    end

    def destroy?
      permission_allowed?(:waiter_service_item, :destroy)
    end

  end
end
