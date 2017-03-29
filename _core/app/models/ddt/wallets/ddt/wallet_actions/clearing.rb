# encoding:utf-8
module Ddt
  module WalletActions
    class Clearing < Ddt::WalletActions::Base

      validate :check_amount

      # 结算
      def perform
        self.wallet.clearing(amount, note: note)
      end

      private
      def check_amount
        self.errors[:amount] << "结算#{amount_name}不能大于现有#{amount_name}" if self.amount > self.wallet.amount.to_f
      end
    end
  end
end