# encoding: utf-8
module Ddt
  class AgentLog < Ddt::Base
    acts_as_type :log_type, [:recharge, :purchase_lisence, :purchase_printer_code, :expiration], %W[充值 购买授权 购买打印机授权码 过期]
    ### relationships
    belongs_to :agent

    default_scope -> {order("created_at DESC")}

    ### validations
    validates :log_type, presence: true
    validates :balance_delta, presence: true

  end
end
