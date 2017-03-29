module Ddt
  module BaseCardWallet
    extend ActiveSupport::Concern
    included do
      def increment_amount(total, cash, extra)
        raise "total:#{total} is not equal to cash:#{cash} + extra:#{extra} on increment_amount" unless is_equal_of?(total,  cash + extra)
        self.increment(:amount, total)
        self.increment(:cash_amount, cash)
        self.increment(:extra_amount, extra)
        self.amount = self.amount.round(2)
        self.cash_amount = self.cash_amount.round(2)
        self.extra_amount = self.extra_amount.round(2)
        self.save!
      end

      def decrement_amount(total, cash, extra)
        raise "total:#{total} is not equal to cash:#{cash} + extra:#{extra} on decrement_amount" unless is_equal_of?(total, cash + extra)
        self.decrement(:amount, total)
        self.decrement(:cash_amount, cash)
        self.decrement(:extra_amount, extra)
        self.amount = self.amount.round(2)
        self.cash_amount = self.cash_amount.round(2)
        self.extra_amount = self.extra_amount.round(2)
        self.save!
      end

      def is_equal_of?(float1, float2)
        (float1 - float2).abs < 0.0001
      end

      def check_amount_correct?
        result = self.wallet_logs.select("SUM(amount) as amount_sum, SUM(cash_amount) as cash_amount_sum, SUM(extra_amount) as extra_amount_sum").first
        if result.amount_sum.present?
          self.amount == self.cash_amount + self.extra_amount &&
            self.amount == result.amount_sum &&
            self.cash_amount == result.cash_amount_sum &&
            self.extra_amount == result.extra_amount_sum
        else
          self.amount == 0
        end
      end

      def get_cash_and_extra_from_total(total)
        # BigDecimal.mode(BigDecimal::ROUND_MODE, BigDecimal::ROUND_HALF_EVEN)
        cash = self.amount != 0 ? total * (self.cash_amount / self.amount) : total
        extra = self.amount != 0 ? total * (self.extra_amount / self.amount) : 0
        cash = BigDecimal.new(cash.to_s).round(2).to_f
        extra = BigDecimal.new(extra.to_s).round(2).to_f
        if is_equal_of?(cash + extra, total + 0.01)
          [cash, (extra - 0.01).round(2)]
        elsif is_equal_of?(cash + extra, total - 0.01)
          [(cash + 0.01).round(2), extra]
        else
          [cash, extra]
        end
      end
    end
  end
end