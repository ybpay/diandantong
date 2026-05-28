# frozen_string_literal: true

module Ddt
  class ExchangeCodePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:exchange_code, :show)
    end

    def exchange?
      permission_allowed?(:exchange_code, :exchange)
    end

  end
end
