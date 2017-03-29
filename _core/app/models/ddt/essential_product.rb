module Ddt
  class EssentialProduct < Ddt::Base
    include BelongsToBranch
    replicated_model

    belongs_to :variant, class_name: 'Ddt::Variant'
    validates_presence_of :variant, :order_type
    validate :quantity, numericality: { greater_than: 0 }

    acts_as_type :order_type, [:eat_in_hall, :delivery], %W[微信堂点 微信外卖]
    delegate :product, to: :variant, allow_nil: true
    scope :eat_in_hall, ->{where(order_type: :eat_in_hall)}
    scope :delivery, ->{where(order_type: :delivery)}

    def essential_quantity(guest_num = 1)
      if is_eat_in_hall?
        per_guest? ? guest_num * quantity : quantity
      elsif is_delivery?
        quantity
      end
    end
  end
end
