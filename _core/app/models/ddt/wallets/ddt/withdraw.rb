#encoding: utf-8
module Ddt
  class Withdraw < Ddt::Base

    include Ddt::BelongsToShop
    include Ddt::Frozenable
    belongs_to :collection_wallet, class_name: 'Ddt::CollectionWallet'

    # 最小提款额
    MIN_AMOUNT = 100.0

    # validates
    # 提款额小于余额，且两者非负
    validates :amount, :numericality => {:greater_than_or_equal_to => MIN_AMOUNT}
    validates :residual, :numericality => {:greater_than_or_equal_to => 0}
    validates_presence_of :alipay_account_id, :alipay_account_name
    validate :residual_must_greater_or_equal_to_amount

    set_shop_from :collection_wallet

    # 只在创建对象时设置提款前余额
    before_validation :set_residual, on: :create

    def transfer_amount
      (self.amount * 0.975).round(2)
    end

    private
    def after_complete
    end

    def after_cancel
      Ddt::Wallet.transaction do
        self.collection_wallet.increment_amount(self.amount, self.amount, 0)
        self.collection_wallet.wallet_logs.create(amount: self.amount, reason: :for_rollback_withdraw, withdraw: self)
      end
    end

    def residual_must_greater_or_equal_to_amount
      if self.residual.present? and self.amount.present?
        errors.add(:residual, '余额不能少于提款额' ) if self.residual < self.amount
      end
    end

    def set_residual
      self.residual = collection_wallet.amount
    end

  end
end