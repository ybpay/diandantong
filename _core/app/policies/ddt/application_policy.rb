# frozen_string_literal: true

module Ddt
  class ApplicationPolicy < ActionPolicy::Base
    authorize :account, allow_nil: true
    authorize :shop, allow_nil: true
    authorize :branch, allow_nil: true

    private

    def admin?
      account&.is_admin?
    end

    def permission_allowed?(target, action)
      return true if admin?
      return false unless account

      scope = branch.present? ? :branch : :shop
      account.can?(scope, target, action, branch_id: branch&.id)
    end
  end
end
