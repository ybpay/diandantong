module Ddt
  module WalletActions
    class Recharge < Ddt::WalletActions::Base

      validates_numericality_of :cash_amount, greater_than: 0, less_than: ::Ddt::Base::MAX_DECIMAL
      validate :check_amount

      # 充值
      def perform
        if self.operator.blank?
          self.operator = (Ddt::Account.current || Ddt::BaseUser.current)
        end
        attrs = {
          note: note,
          branch: current_branch,
          operator: self.operator
        }
        self.wallet.recharge(amount, cash_amount, attrs)
      end

      def self.human_attribute_name(attribute, options={})
        {
          amount: "到账金额",
          cash_amount: "充值金额",
          note: "备注"
        }[attribute.to_sym] || super
      end

      private
      def check_amount
        self.errors[:cash_amount] << "充值金额不能大于实际到账金额" if cash_amount.to_f > amount.to_f
      end
    end
  end
end
