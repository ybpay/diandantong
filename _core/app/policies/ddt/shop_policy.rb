# frozen_string_literal: true

module Ddt
  class ShopPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:shop, :show)
    end

    def dashboard?
      permission_allowed?(:shop, :dashboard)
    end

    def home?
      permission_allowed?(:shop, :home)
    end

    def update?
      permission_allowed?(:shop, :update)
    end
  end
end
