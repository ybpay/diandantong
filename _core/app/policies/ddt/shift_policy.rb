# frozen_string_literal: true

module Ddt
  class ShiftPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:shift, :show)
    end

  end
end
