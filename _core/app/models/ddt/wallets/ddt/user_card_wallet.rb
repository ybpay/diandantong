# encoding:utf-8
module Ddt
  class UserCardWalletAmountNotEnough < StandardError; end;
  class UserCardWallet < Ddt::UserWallet
    include Ddt::BaseCardWallet
    has_many :card_deductions, class_name: "Ddt::CardDeduction", foreign_key: :wallet_id
    alias_method :deductions, :card_deductions
    # amount 总金额 = cash_amount + extra_amount
    # cash_amount 现金账户余额
    # extra_amount 附属账户余额

    scope :not_default, -> {
      joins("LEFT JOIN ddt_vip_infos on ddt_wallets.owner_id = ddt_vip_infos.id")
      .joins("JOIN ddt_vip_levels on ddt_vip_infos.vip_level_id = ddt_vip_levels.id")
      .where("ddt_vip_infos.id is not null and ddt_vip_levels.is_default = 0")
    }

    # 充值
    # options: {note, branch, operator}
    def recharge(total, cash, options={})
      note = options[:note]
      branch = options[:branch]
      operator = options[:operator]
      with_lock do
        extra = total - cash
        self.owner.increment!(:total_recharge_money, cash) if self.owner_type == "Ddt::VipInfo"
        self.increment!(:total_recharge_money, cash)
        self.increment_amount(total, cash, extra)
        self.wallet_logs.create(
          amount:       total,
          cash_amount:  cash,
          extra_amount: extra,
          reason:       :for_recharge,
          note:         note,
          branch_id:    branch.try(:id),
          operator:     operator,
          pay_method:   shop.pay_on_face_pay_method,
          pay_method_name: shop.pay_on_face_pay_method.name
        )
        check_auto_upgrade
        if branch.present?
          wallet = branch.card_wallet
          wallet.decrement_amount(total, cash, extra)
          wallet.wallet_logs.create(amount: -total, cash_amount: -cash, extra_amount: -extra, note: note, reason: :for_recharge)
        else
          wallet = self.shop_wallet
          wallet.increment_amount(total, cash, extra)
        end
      end
      send_wallet_change_notify
    end

    # 充值产品充值
    # options: {note, branch, operator}
    def recharge_with_product(recharge_product, pay_method_names = nil, options={})
      order = options[:order]
      note = options[:note]
      branch = options[:branch]
      operator = options[:operator] || self.owner
      with_lock do
        total = recharge_product.recharge_amount
        cash = recharge_product.price
        extra = total - cash
        self.owner.increment!(:total_recharge_money, cash) if self.owner_type == "Ddt::VipInfo"
        self.increment(:total_recharge_money, cash)
        self.increment_amount(total, cash, extra)
        wallet = self.shop_wallet
        wallet.increment_amount(total, cash, extra)
        wallet_log_attrs = {
          amount: total,
          cash_amount: cash,
          extra_amount: extra,
          note: recharge_product.name,
          reason: :for_recharge,
          operator: operator,
          note:         note,
          branch_id:    branch.try(:id),
          order: order
        }
        if pay_method_names.present?
          pay_methods = self.shop.pay_methods.with_discarded.where(name: pay_method_names.split(" "))
          wallet_log_attrs[:pay_method_name] = pay_method_names
          wallet_log_attrs[:pay_method] = pay_methods.first if pay_methods.present? && pay_methods.count == 1
        end
        self.wallet_logs.create(wallet_log_attrs)
        check_auto_upgrade
        if branch.present?
          wallet = branch.card_wallet
          wallet.decrement_amount(total, cash, extra)
          wallet.wallet_logs.create(amount: -total, cash_amount: -cash, extra_amount: -extra, note: note, reason: :for_recharge, order: order)
        else
          wallet = self.shop_wallet
          wallet.increment_amount(total, cash, extra)
        end
      end
      send_wallet_change_notify
    end

    # 会员卡支付
    def pay(order, amount)
      with_lock do
        total = amount.to_f
        cash, extra = get_cash_and_extra_from_total(total)
        self.owner.increment!(:vip_card_consume_amount, amount)
        self.decrement_amount(total, cash, extra)
        self.wallet_logs.create(amount: -total, cash_amount: -cash, extra_amount: -extra, reason: :for_vip_card_pay, order: order)
        wallet = order.branch.card_wallet
        wallet.increment_amount(total, cash, extra)
        wallet.wallet_logs.create(amount: total, cash_amount: cash, extra_amount: extra, reason: :for_vip_card_pay, order: order)
      end
      send_wallet_change_notify
    rescue ActiveRecord::RecordInvalid => e
      total = amount.to_f
      cash, extra = get_cash_and_extra_from_total(total)
      raise UserCardWalletAmountNotEnough.new("余额不足 wallet(#{amount}, #{cash_amount}, #{extra_amount}) pay(#{total}, #{cash}, #{extra}) #{e.message}")
    end

    # 回滚
    def rollback(order, amount, cash, extra)
      with_lock do
        total = amount.to_f
        self.increment_amount(total, cash, extra)
        pay_log = self.wallet_logs.find_by(reason: :for_vip_card_pay, order_id: order.id)
        self.wallet_logs.create(amount: total, cash_amount: cash, extra_amount: extra, reason: :for_rollback_vip_card_pay, order: order, st_time: pay_log.created_at)
        wallet = order.branch.card_wallet
        wallet.decrement_amount(total, cash, extra)
        wallet.wallet_logs.create(amount: -total, cash_amount: -cash, extra_amount: -extra, reason: :for_rollback_vip_card_pay, order: order, st_time: pay_log.created_at)
      end
      send_wallet_change_notify
    end

    # 合并
    def merge(wallet)
      with_lock do
        self.owner.increment!(:total_recharge_money, wallet.total_recharge_money) if self.owner_type == "Ddt::VipInfo"
        self.increment!(:total_recharge_money, wallet.total_recharge_money)
        self.increment_amount(wallet.amount, wallet.cash_amount, wallet.extra_amount)
        self.wallet_logs.create(amount: wallet.amount, cash_amount: wallet.cash_amount, extra_amount: wallet.extra_amount, reason: :for_vip_merge)
      end
      send_wallet_change_notify
    end

    # 兑换
    def exchange(amount, note: nil, branch: nil)
      with_lock do
        total = amount.to_f
        cash, extra = get_cash_and_extra_from_total(total)
        self.decrement_amount(total, cash, extra)
        self.wallet_logs.create(amount: -total, cash_amount: -cash, extra_amount: -extra, note: note, reason: :for_exchange, branch_id: branch.try(:id))
        if branch.present?
          wallet = branch.card_wallet
          wallet.increment_amount(total, cash, extra)
          wallet.wallet_logs.create(amount: total, cash_amount: cash, extra_amount: extra, note: note, reason: :for_exchange)
        else
          wallet = self.shop_wallet
          wallet.decrement_amount(total, cash, extra)
        end
      end
      send_wallet_change_notify
    end

    # 获得
    def get(extra, note: nil, branch: nil)
      with_lock do
        self.increment_amount(extra, 0, extra)
        if branch.present?
          wallet = branch.card_wallet
          wallet.decrement_amount(extra, 0, extra)
          wallet.wallet_logs.create(amount: -extra, extra_amount: -extra, note: note, reason: :for_grant, branch_id: branch.try(:id))
        else
          wallet = self.shop_wallet
          wallet.increment_amount(extra, 0, extra)
        end
        self.wallet_logs.create(amount: extra, extra_amount: extra, note: note, reason: :for_grant)
      end
      send_wallet_change_notify
    end

    # 抵扣
    def deduct(deduction)
      with_lock do
        total = deduction.amount
        cash, extra = get_cash_and_extra_from_total(total)
        self.decrement_amount(total, cash, extra)
        self.wallet_logs.create(amount: -total, cash_amount: -cash, extra_amount: -extra, reason: :for_deduction, deduction: deduction)
      end
      send_wallet_change_notify
    end

    # 抵扣回退
    def cancel_deduction(deduction)
      with_lock do
        self.increment_amount(deduction.amount, deduction.cash_amount, deduction.extra_amount)
        deduct_log = self.wallet_logs.find_by(reason: :for_deduction, order_id: deduction.order_id)
        self.wallet_logs.create(amount: deduction.amount, cash_amount: deduction.cash_amount, extra_amount: deduction.extra_amount, reason: :for_deduction_cancel, deduction: deduction, st_time: deduct_log.created_at)
      end
    end

    # 充值退款
    def recharge_refund(total, cash, extra, order)
      with_lock do
        self.owner.decrement!(:total_recharge_money, cash) if self.owner_type == "Ddt::VipInfo"
        self.decrement_amount(total, cash, extra)
        self.wallet_logs.create(amount: -total, cash_amount: -cash, extra_amount: -extra, reason: :for_recharge_refund, order: order, operator: order.operator)
      end
      send_wallet_change_notify
    end

    # 充值退款撤销
    def cancel_recharge_refund(amount, cash, extra, order)
      with_lock do
        self.owner.increment!(:total_recharge_money, cash) if self.owner_type == "Ddt::VipInfo"
        self.increment_amount(amount, cash, extra)
        recharge_log = self.wallet_logs.find_by(reason: :for_recharge, order_id: order.id)
        self.wallet_logs.create(amount: amount, cash_amount: cash, extra_amount: extra, reason: :for_recharge_refund_cancel, order: order, st_time: recharge_log.created_at)
      end
    end

    # 充值退款完成
    def complete_recharge_refund(amount, cash, extra, order)
      with_lock do
        recharge_log = self.wallet_logs.find_by(reason: :for_recharge, order_id: order.id)
        self.wallet_logs.create(amount: -amount, cash_amount: -cash, extra_amount: -extra, reason: :for_recharge_refund_complete, order: order, st_time: recharge_log.created_at)
      end
    end

    # 导入
    def import(amount)
      with_lock do
        pre_amount = self.amount
        pre_cash_amount = self.cash_amount
        pre_extra_amount = self.extra_amount
        import_amount = amount.try(:to_f)
        if import_amount.present? && import_amount != pre_amount
          self.update_columns(amount: import_amount, cash_amount: import_amount, extra_amount: 0)
          self.wallet_logs.create(amount: import_amount-pre_amount, cash_amount: import_amount - pre_cash_amount, extra_amount: -pre_extra_amount, reason: :for_import)
        end
      end
    end

    def shop_wallet
      self.shop.card_wallet
    end
  end
end
