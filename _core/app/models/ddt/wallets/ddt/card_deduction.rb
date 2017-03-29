# encoding:utf-8
module Ddt
  class CardDeduction < Ddt::Deduction
    belongs_to :wallet, class_name: 'Ddt::UserCardWallet'
    validates :amount, numericality:  { greater_than_or_equal_to: 0 }
    validates :cash_amount, numericality:  { greater_than_or_equal_to: 0 }
    validates :extra_amount, numericality:  { greater_than_or_equal_to: 0 }
    def after_complete
      self.branch_wallet.complete_deduction(self)
    end

    def after_cancel
      self.wallet.cancel_deduction(self)
    end

    concerning :AdjustSource do
      def compute_amount_of_adjustment(order)
        - self.amount
      end

      def get_label_of_adjustment(order)
        '余额抵扣'
      end
    end

    def branch_wallet
      self.order.branch.card_wallet
    end
  end
end