# frozen_string_literal: true

module Ddt
  class DdbModulePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:ddb_module, :show)
    end

    def update?
      permission_allowed?(:ddb_module, :update)
    end

  end
end
