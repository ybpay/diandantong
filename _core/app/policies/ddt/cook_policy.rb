# frozen_string_literal: true

module Ddt
  class CookPolicy < ApplicationPolicy
    def manage?
      permission_allowed?(:cook, :manage)
    end

  end
end
