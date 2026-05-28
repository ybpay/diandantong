# frozen_string_literal: true

module Ddt
  class MerchantApplyPolicy < ApplicationPolicy
    def manage?
      permission_allowed?(:merchant_apply, :manage)
    end

  end
end
