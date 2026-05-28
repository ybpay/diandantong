# frozen_string_literal: true

module Ddt
  class TablePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:table, :show)
    end

    def create?
      permission_allowed?(:table, :create)
    end

    def update?
      permission_allowed?(:table, :update)
    end

    def destroy?
      permission_allowed?(:table, :destroy)
    end

    def open?
      permission_allowed?(:table, :open)
    end

    def bind_table?
      permission_allowed?(:table, :bind_table)
    end

    def clear?
      permission_allowed?(:table, :clear)
    end

    def check_out?
      permission_allowed?(:table, :check_out)
    end

    def cancel_check_out?
      permission_allowed?(:table, :cancel_check_out)
    end

    def update_guest_num?
      permission_allowed?(:table, :update_guest_num)
    end

    def force_clear?
      permission_allowed?(:table, :force_clear)
    end
  end
end
