# encoding:utf-8
module Ddt
  class CreditsDeduction < Ddt::Deduction
    belongs_to :wallet, class_name: 'Ddt::UserCreditsWallet'
    validates :credits, numericality: { greater_than_or_equal_to: 0 }
    def after_complete
      self.branch_wallet.complete_deduction(self)
    end

    def after_cancel
      self.wallet.cancel_deduction(self)
    end

    concerning :AdjustSource do
      def compute_amount_of_adjustment(order)
        - self.amount * 1.0 / self.shop.credits_setting.exchange_radio
      end

      def get_label_of_adjustment(order)
        '积分抵扣'
      end
    end

    def branch_wallet
      self.order.branch.credits_wallet
    end

    def amount
      self.credits
    end

    def amount=(value)
      self.credits=(value)
    end
  end
end