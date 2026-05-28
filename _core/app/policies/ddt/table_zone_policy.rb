# frozen_string_literal: true

module Ddt
  class TableZonePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:table_zone, :show)
    end

    def create?
      permission_allowed?(:table_zone, :create)
    end

    def update?
      permission_allowed?(:table_zone, :update)
    end

    def destroy?
      permission_allowed?(:table_zone, :destroy)
    end

  end
end
