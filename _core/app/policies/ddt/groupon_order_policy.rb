# frozen_string_literal: true

module Ddt
  class GrouponOrderPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:groupon_order, :show)
    end

    def confirm?
      permission_allowed?(:groupon_order, :confirm)
    end

    def complete?
      permission_allowed?(:groupon_order, :complete)
    end

    def cancel?
      permission_allowed?(:groupon_order, :cancel)
    end

    def reprint?
      permission_allowed?(:groupon_order, :reprint)
    end

    def settle?
      permission_allowed?(:groupon_order, :settle)
    end

    def append_pay_item?
      permission_allowed?(:groupon_order, :append_pay_item)
    end
  end
end
