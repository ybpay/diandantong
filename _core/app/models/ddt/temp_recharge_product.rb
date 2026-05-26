module Ddt
  class TempRechargeProduct < Ddt::Base
    include BelongsToShop

    include Ddt::SoftDeletable

    validates_presence_of :price, :recharge_amount
    validates_numericality_of :price, :recharge_amount, :greater_than => 0
    validates_numericality_of :extra_credits, :greater_than_or_equal_to => 0

    before_create :set_name

    def branch
      self.shop.abstract_branch
    end

    def branch_id
      branch.id
    end

    def first_recharge_available_amount
      self.price
    end

    def set_name
      self.name = "#{self.price}充#{self.recharge_amount}"
    end

    concerning :ItemableMethod do
      include Itemable
      included do
        # column : name price
        def sku
        end

        def itemable_name
          self.name
        end
        alias_method :product_name, :itemable_name

        def stock_enough?(quantity=1)
          true
        end

        def stock_quantity
          999999
        end

        def original_price
          price
        end

        def vip_price
          price
        end

        def unit_name
          ''
        end

        def avatar_url
        end

        def update_sale_quantity(line_item_quantity)
        end
      end
    end
  end
end
