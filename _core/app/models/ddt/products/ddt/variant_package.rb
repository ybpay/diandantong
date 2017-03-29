module Ddt
  class VariantPackage < Ddt::Base
    include BelongsToBranch
    include Itemable
    replicated_model


    belongs_to_order
    belongs_to :variant, ->{with_deleted}

    validates_presence_of :variant
    validates :weight, numericality: { greater_than: 0}

    delegate :name, :sku, :product_name, :product_id, :stock_quantity, :stock_enough?, :unit_name, :avatar_url, :update_stock_quantity, :update_sale_quantity, :rollback_stock_quantity, :enable_discount, :enable_discount?, :category_ids, :category_names, :enable_change_price, to: :variant
    set_shop_and_branch_from :variant

    scope :with_deleted, ->{}

    before_save :set_itemable_name

    [:original_price, :price, :vip_price].each do |price_type|
      define_method price_type do
        weight * variant.send(price_type)
      end
    end

    def cache_name
      itemable_name
    end

    def to_stockables
      [self.variant]
    end

    private

     def set_itemable_name
       self.itemable_name = "#{variant.itemable_name}(重量: #{self.weight}#{self.unit_name})"
     end


  end
end
