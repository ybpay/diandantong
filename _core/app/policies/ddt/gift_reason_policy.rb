# frozen_string_literal: true

module Ddt
  class GiftReasonPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:gift_reason, :show)
    end

    def create?
      permission_allowed?(:gift_reason, :create)
    end

    def update?
      permission_allowed?(:gift_reason, :update)
    end

    def destroy?
      permission_allowed?(:gift_reason, :destroy)
    end

  end
end
