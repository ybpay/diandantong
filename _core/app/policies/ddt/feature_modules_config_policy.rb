# frozen_string_literal: true

module Ddt
  class FeatureModulesConfigPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:feature_modules_config, :show)
    end

    def update?
      permission_allowed?(:feature_modules_config, :update)
    end

  end
end
