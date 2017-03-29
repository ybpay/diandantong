# encoding:utf-8
module Ddt
  module WalletActions
    class Exchange < Ddt::WalletActions::Base

      validate :check_amount

      # 兑换
      def perform
        self.wallet.exchange(amount, note: note, branch: current_branch)
      end

      def self.human_attribute_name(attribute, options={})
        {
          amount: "兑换额",
          note: "备注"
        }[attribute.to_sym] || super
      end

      private
      def check_amount
        self.errors[:amount] << "兑换#{amount_name}不能大于现有#{amount_name}" if self.amount > self.wallet.amount.to_f
      end
    end
  end
end