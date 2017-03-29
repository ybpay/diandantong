# encoding:utf-8
module Ddt
  class BranchCardWallet < Ddt::BranchWallet
    include Ddt::BaseCardWallet
    # 结算
    def clearing(total, note:nil)
      with_lock do
        cash, extra = get_cash_and_extra_from_total(total)
        self.decrement_amount(total, cash, extra)
        self.shop_wallet.decrement_amount(total, cash, extra)
        self.wallet_logs.create(amount: -total, cash_amount: -cash, extra_amount: -extra, note: note, reason: :for_clearing)
      end
    end

    # 抵扣完成
    def complete_deduction(deduction)
      with_lock do
        self.increment_amount(deduction.amount, deduction.cash_amount, deduction.extra_amount)
        self.wallet_logs.create(amount: deduction.amount, cash_amount: deduction.cash_amount, extra_amount: deduction.extra_amount, reason: :for_deduction_complete, deduction: deduction)
      end
    end

    # 充值退款完成
    def complete_recharge_refund(amount, cash, extra, order)
      with_lock do
        self.increment_amount(amount, cash, extra)
        recharge_log = self.wallet_logs.find_by(reason: :for_recharge, order_id: order.id)
        self.wallet_logs.create(amount: amount, cash_amount: cash, extra_amount: extra, reason: :for_recharge_refund_complete, order: order, st_time: recharge_log.created_at)
      end
    end

    def shop_wallet
      self.shop.card_wallet
    end
  end
end
