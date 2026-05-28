# frozen_string_literal: true

module Ddt
  class WechatAccountPolicy < ApplicationPolicy
    def manage?
      permission_allowed?(:wechat_account, :manage)
    end

  end
end
