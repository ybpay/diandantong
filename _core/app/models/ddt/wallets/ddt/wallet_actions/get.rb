module Ddt
  module WalletActions
    class Get < Ddt::WalletActions::Base

      validates_numericality_of :amount, greater_than: 0, less_than: ::Ddt::Base::MAX_DECIMAL

      # 充值
      def perform
        self.wallet.get(amount, note: note, branch: current_branch, operator: self.operator)
      end

      def self.human_attribute_name(attribute, options={})
        {
          amount: "积分数量",
          note: "备注"
        }[attribute.to_sym] || super
      end

    end
  end
end
