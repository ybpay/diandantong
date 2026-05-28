# frozen_string_literal: true

module Ddt
  class LitpPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:litp, :show)
    end

    def confirm_litp?
      permission_allowed?(:litp, :confirm_litp)
    end

    def complete_litp?
      permission_allowed?(:litp, :complete_litp)
    end

  end
end
