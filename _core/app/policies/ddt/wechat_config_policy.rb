# frozen_string_literal: true

module Ddt
  class WechatConfigPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:wechat_config, :show)
    end

    def update?
      permission_allowed?(:wechat_config, :update)
    end

  end
end
