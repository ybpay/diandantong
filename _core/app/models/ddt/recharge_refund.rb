module Ddt
  class RechargeRefund < Base
    include BelongsToBranch
    belongs_to_order
    belongs_to :vip_info
    belongs_to :operator, class_name: "Account"
    delegate :name, to: :operator, prefix: true
    belongs_to :reviewer, class_name: "Account"
    delegate :name, to: :reviewer, prefix: true
    default_scope ->{ order(created_at: :desc)}
    acts_as_type :state, [:pending, :completed, :canceled], %W(已冻结 已完成 已撤消)
    # credits amount cash_amount extra_amount
    state_machine :state, initial: :pending do
      event :complete do
        transition from: :pending, to: :completed
      end
      event :cancel do
        transition from: :pending, to: :canceled
      end
      after_transition on: :complete, do: :after_complete
      after_transition on: :cancel, do: :after_cancel
    end

    def after_complete
      if self.credits > 0
        branch.credits_wallet.complete_recharge_refund(self.credits, order)
        self.vip_info.credits_wallet.complete_recharge_refund(self.credits, order) if self.credits > 0
      end
      branch.card_wallet.complete_recharge_refund(self.amount, self.cash_amount, self.extra_amount, order)
      self.vip_info.card_wallet.complete_recharge_refund(self.amount, self.cash_amount, self.extra_amount, order)
      order.complete_refund
    end

    def after_cancel
      vip_info.credits_wallet.cancel_recharge_refund(self.credits, order) if self.credits > 0
      self.vip_info.card_wallet.cancel_recharge_refund(self.amount, self.cash_amount, self.extra_amount, order)
      order.cancel_refund
    end

    def self.init_refund(order)
      transaction do
        order.errors[:base] << "剩余积分不足" if order.vip_info.credits_wallet.amount < order.total_extra_credits
        order.errors[:base] << "剩余余额不足" if order.vip_info.card_wallet.amount < order.total_recharge_amount
        if order.errors.blank?
          refund = ::Ddt::RechargeRefund.create({
              shop: order.shop,
              branch: order.branch,
              vip_info: order.vip_info,
              order: order,
              order_number: order.number,
              operator: order.operator,
              credits: order.total_extra_credits,
              amount: order.total_recharge_amount,
              cash_amount: order.total_cash_amount,
              extra_amount: order.total_extra_amount,
            })
          refund.vip_info.credits_wallet.recharge_refund(refund.credits, order) if refund.credits > 0
          refund.vip_info.card_wallet.recharge_refund(refund.amount, refund.cash_amount, refund.extra_amount, order)
          refund
        end
      end
    end
  end
end
