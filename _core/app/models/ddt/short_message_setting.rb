# encoding: utf-8
module Ddt
  class ShortMessageSetting < Ddt::Base
    has_paper_trail only: [:max_count]
    ### relationships
    belongs_to :shop

    ### validations
    validates :shop, presence: true
    validates :used_count, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
    validates :max_count, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}

    def remaining_count
      max_count - used_count
    end

    def recharge(count)
      self.increment!(:max_count, count)
    end

    def can_use_validation_sms?
      use_sms? && use_validation_sms?
    end

    def can_use_order_sms?
      use_sms? && use_order_sms?
    end

  end
end
