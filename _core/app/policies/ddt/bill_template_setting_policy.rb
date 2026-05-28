# frozen_string_literal: true

module Ddt
  class BillTemplateSettingPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:bill_template_setting, :show)
    end

    def update?
      permission_allowed?(:bill_template_setting, :update)
    end

  end
end
