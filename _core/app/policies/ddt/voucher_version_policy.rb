# frozen_string_literal: true

module Ddt
  class VoucherVersionPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:voucher_version, :show)
    end

    def create?
      permission_allowed?(:voucher_version, :create)
    end

    def update?
      permission_allowed?(:voucher_version, :update)
    end

    def destroy?
      permission_allowed?(:voucher_version, :destroy)
    end

  end
end
