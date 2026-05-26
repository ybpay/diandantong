module Ddt
  class ShiftItem < Ddt::Base
    include BelongsToBranch

    belongs_to :shift
    belongs_to :pay_method, ->{ with_deleted }
    acts_as_paranoid
    set_from :shift
    before_create :set_pay_method_info
    acts_as_type :item_type, [:base, :recharge]
    validates :amount, :numericality => {:greater_than_or_equal_to => 0, :less_than => 99990000}
    scope :base, ->{ where(item_type: :base)}
    scope :recharge, ->{ where(item_type: :recharge)}
    attr_accessor :not_actual_amount

    def self.item_type_of(order)
      order.class.recharge_types.include?(order.type) ? :recharge : :base
    end

    def not_actual_amount
      if actual_amount != amount
        amount - actual_amount
      end
    end

    private
    def set_pay_method_info
      self.pay_method_name = self.pay_method.try(:name) if self.pay_method_name.blank?
      self.pay_method_code = self.pay_method.try(:code) if self.pay_method_code.blank?
      true
    end
  end
end
