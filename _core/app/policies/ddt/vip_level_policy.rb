# frozen_string_literal: true

module Ddt
  class VipLevelPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:vip_level, :show)
    end

    def create?
      permission_allowed?(:vip_level, :create)
    end

    def update?
      permission_allowed?(:vip_level, :update)
    end

    def destroy?
      permission_allowed?(:vip_level, :destroy)
    end

  end
end
