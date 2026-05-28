# frozen_string_literal: true

module Ddt
  class EventPromotionPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:event_promotion, :show)
    end

    def create?
      permission_allowed?(:event_promotion, :create)
    end

    def update?
      permission_allowed?(:event_promotion, :update)
    end

    def destroy?
      permission_allowed?(:event_promotion, :destroy)
    end

  end
end
