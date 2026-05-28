# frozen_string_literal: true

module Ddt
  class VoucherPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:voucher, :show)
    end

    def exchange?
      permission_allowed?(:voucher, :exchange)
    end
  end
end
