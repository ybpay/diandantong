# encoding:utf-8
module Ddt
  # 待收款钱包
  class CollectionWallet < Ddt::ShopWallet
    include Ddt::BaseCardWallet

    has_many :withdraws, class_name: 'Ddt::Withdraw'
    validates :amount, :numericality => {:greater_than_or_equal_to => 0}

    # 收款
    def collect(payment)
      Ddt::Wallet.transaction do
        increment_amount(payment.amount, payment.amount, 0)
        self.wallet_logs.create(amount: payment.amount, order: payment.order, reason: :for_collection)
      end
    end

    #
    # 提款
    #
    def withdraw(withdraw_object_or_params)
      # 生成提款记录以及钱包日志
      withdraw = nil
      Ddt::Wallet.transaction do
        if withdraw_object_or_params.is_a? Ddt::Withdraw
          withdraw = withdraw_object_or_params
        else
          withdraw = self.withdraws.build(withdraw_object_or_params)
          return withdraw unless withdraw.save
        end

        decrement_amount(withdraw.amount, withdraw.amount, 0)
        self.wallet_logs.create!(amount: -withdraw.amount, reason: :for_withdraw, withdraw: withdraw)
      end
      withdraw
    end

  end
end
