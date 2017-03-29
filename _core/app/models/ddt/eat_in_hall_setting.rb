#encoding: utf-8
module Ddt
  class EatInHallSetting < Ddt::Base
    include BelongsToBranchWithTouch
    replicated_model

    # auto_clear_table

    PAY_AFTER_MODE = "pay_after"
    PAY_BEFORE_MODE = "pay_before"

    acts_as_type :mode, [:pay_after, :pay_before], %W[后付款模式 预付款模式]
    acts_as_type :confirm_type, [:confirm_auto, :confirm_by_distance, :confirm_manual], %W[自动确认 自动确认(距离限制) 手动确认]

  end
end
