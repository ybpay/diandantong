# frozen_string_literal: true

module Ddt
  class GrouponPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:groupon, :show)
    end

    def exchange?
      permission_allowed?(:groupon, :exchange)
    end
  end
end
