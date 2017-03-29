# encoding:utf-8
module Ddt
  class BranchCreditsWallet < Ddt::BranchWallet
    include Ddt::BaseCreditsWallet
    # 结算
    def clearing(amount, note:nil)
      transaction do
        self.decrement_amount(amount)
        self.shop_wallet.decrement_amount(amount)
        self.wallet_logs.create(amount: -amount, note: note, reason: :for_clearing)
      end
    end

    # 抵扣完成
    def complete_deduction(deduction)
      transaction do
        self.increment_amount(deduction.amount)
        self.wallet_logs.create(amount: deduction.amount, reason: :for_deduction_complete, deduction: deduction)
      end
    end

    # 充值退款完成
    def complete_recharge_refund(amount, order)
      transaction do
        self.increment_amount(amount)
        grant_log = self.wallet_logs.find_by(reason: :for_grant, order_id: order.id, note: '充值赠送')
        self.wallet_logs.create(amount: amount, reason: :for_recharge_refund_complete, order: order, st_time: grant_log.created_at)
      end
    end

    def shop_wallet
      self.shop.credits_wallet
    end
  end
end
