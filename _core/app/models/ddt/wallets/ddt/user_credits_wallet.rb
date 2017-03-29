# encoding:utf-8
module Ddt
  class UserCreditsWallet < Ddt::UserWallet
    include Ddt::BaseCreditsWallet
    has_many :credits_deductions, class_name: "Ddt::CreditsDeduction", foreign_key: :wallet_id
    alias_method :deductions, :credits_deductions

    # 兑换
    def exchange(amount, note: nil, branch: nil)
      with_lock do
        self.decrement_amount(amount)
        self.increment!(:total_used_credits, amount)
        self.wallet_logs.create(amount: -amount, note: note, reason: :for_exchange)
        if branch.present?
          branch.credits_wallet.increment_amount(amount)
          branch.credits_wallet.wallet_logs.create(amount: amount, note: note, reason: :for_exchange)
        else
          self.shop_wallet.decrement_amount(amount)
        end
      end
      send_wallet_change_notify
    end

    # 获得
    def get(amount, note: nil, branch: nil, order: nil, operator: nil)
      with_lock do
        self.increment_amount(amount)
        self.increment!(:total_get_credits, amount)
        check_auto_upgrade
        self.wallet_logs.create(amount: amount, note: note, reason: :for_grant, order: order, operator: operator)
        if branch.present?
          branch.credits_wallet.decrement_amount(amount)
          branch.credits_wallet.wallet_logs.create(amount: -amount, note: note, reason: :for_grant, order: order, operator: operator)
        else
          self.shop_wallet.increment_amount(amount)
        end
      end
      send_wallet_change_notify
      if self.wallet_logs.where(created_at: Time.now.beginning_of_day..Time.now.end_of_day, reason: :for_grant).where("amount >= 500").count >= 2 && amount >= 500
        SystemMessage.send_to_shop(self.shop_id, :exception, "用户(id:#{self.owner_id})积分赠送异常")
      end
    end

    # 抵扣
    # def deduct_for_order(order, amount)
    def deduct(deduction)
      with_lock do
        self.increment!(:total_used_credits, deduction.amount)
        self.decrement_amount(deduction.amount)
        self.wallet_logs.create(amount: -deduction.amount, reason: :for_deduction, deduction: deduction)
      end
      send_wallet_change_notify
    end

    def cancel_deduction(deduction)
      with_lock do
        self.increment_amount(deduction.amount)
        deduct_log = self.wallet_logs.find_by(reason: :for_deduction, order_id: deduction.order_id)
        self.wallet_logs.create(amount: deduction.amount, reason: :for_deduction_cancel, deduction: deduction, st_time: deduct_log.created_at)
      end
    end

    def recharge_refund(amount, order)
      with_lock do
        self.decrement_amount(amount)
        self.decrement!(:total_get_credits, amount)
        self.wallet_logs.create(amount: -amount, note: "充值赠送退款", reason: :for_recharge_refund, order: order, operator: order.operator)
      end
      send_wallet_change_notify
    end

    def cancel_recharge_refund(amount, order)
      with_lock do
        self.increment_amount(amount)
        self.increment!(:total_get_credits, amount)
        grant_log = self.wallet_logs.find_by(reason: :for_grant, order_id: order.id, note: '充值赠送')
        self.wallet_logs.create(amount: amount, note: "充值赠送退款回退", reason: :for_recharge_refund_cancel, order: order, st_time: grant_log.created_at)
      end
    end

    def complete_recharge_refund(amount, order)
      with_lock do
        grant_log = self.wallet_logs.find_by(reason: :for_grant, order_id: order.id, note: '充值赠送')
        self.wallet_logs.create(amount: -amount, note: "充值赠送退款完成", reason: :for_recharge_refund_complete, order: order, st_time: grant_log.created_at)
      end
    end

    # 合并
    def merge(wallet)
      with_lock do
        self.increment(:total_get_credits, wallet.total_get_credits)
        self.increment(:total_used_credits, wallet.total_used_credits)
        self.save!
        self.increment_amount(wallet.amount)
        self.wallet_logs.create(amount: wallet.amount, reason: :for_vip_merge)
      end
      send_wallet_change_notify
    end

    # 导入
    def import(amount)
      with_lock do
        pre_amount = self.amount
        import_amount = amount.try(:to_i)
        if import_amount.present? && import_amount != pre_amount
          self.update_column(:credits, import_amount)
          self.wallet_logs.create(amount: import_amount-pre_amount, reason: :for_import)
        end
      end
    end

    # 清零
    def credits_clear
      with_lock do
        pre_amount = self.amount
        self.update_column(:credits, 0)
        self.wallet_logs.create(amount: -pre_amount, reason: :for_credits_clear)
      end
    end

    def shop_wallet
      self.shop.credits_wallet
    end

  end
end
