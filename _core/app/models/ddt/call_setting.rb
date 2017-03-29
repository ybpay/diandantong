# encoding: utf-8
module Ddt
  class CallSetting < Ddt::Base
    belongs_to :shop

    validates :shop, presence: true
    validates :used_amount, numericality: { greater_than_or_equal_to: 0}

    def can_order_call?
      enable_order_call? && amount > 0
    end

    def cost(cost_amount)
      if self.amount >= cost_amount
        self.used_amount = self.used_amount + cost_amount
        self.amount = self.amount - cost_amount
      elsif self.amount > 0
        self.used_amount = self.used_amount + self.amount
        self.amount = self.amount - cost_amount
      end
      self.save!
    end


  end
end
