# frozen_string_literal: true

module Ddt
  class QrcodePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:qrcode, :show)
    end

    def create?
      permission_allowed?(:qrcode, :create)
    end

    def update?
      permission_allowed?(:qrcode, :update)
    end

    def destroy?
      permission_allowed?(:qrcode, :destroy)
    end

  end
end
