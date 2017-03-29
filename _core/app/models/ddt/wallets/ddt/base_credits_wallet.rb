module Ddt
  module BaseCreditsWallet
    extend ActiveSupport::Concern
    included do
      def amount
        self.credits
      end

      def amount=(value)
        self.credits=(value)
      end

      def increment_amount(amount)
        self.increment(:credits, amount)
        self.save!
      end

      def decrement_amount(amount)
        self.decrement(:credits, amount)
        self.save!
      end

      def check_amount_correct?
        result = self.wallet_logs.select("SUM(amount) as amount_sum").first
        if result.amount_sum.present?
          self.amount == result.amount_sum
        else
          self.amount == 0
        end
      end
    end

  end
end