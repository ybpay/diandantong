module Ddt
  module Itemable
    extend ActiveSupport::Concern
    included do
      has_many :line_items, class_name: 'Ddt::LineItem', as: :itemable
      # itemable class
      #   Variant VariantPackage ComboPackage GrouponVersion VoucherVersion RechargeProduct
      # itemable_type
      #   Variant VariantPackage ComboPackage AbstractCouponVersion RechargeProduct
      [
        :sku,
        :name,
        :product_name,
        :itemable_name,
        :original_price,
        :price,
        :vip_price,
        :stock_quantity,
        :unit_name,
        :avatar_url,
      ].each do |method_name|
        if !(self.table_exists? && ActiveRecord::Base.connection.column_exists?(table_name, method_name)) && !self.method_defined?(method_name)
          define_method method_name do
            raise NotImplementedError, "method :#{method_name} should be implement as itemable"
          end
        end
      end

      def itemable_type
        self.class.base_class.name
      end

      def itemable_id
        id
      end

      if !(self.table_exists? && ActiveRecord::Base.connection.column_exists?(table_name, :min_quantity_for_order)) && !self.method_defined?(:min_quantity_for_order)
        define_method :min_quantity_for_order do
          1
        end
      end

      if !self.method_defined?(:stock_enough?)
        define_method "stock_enough?" do |require_num=1|
          true
        end
      end

      if !self.method_defined?(:enable_discount)
        define_method :enable_discount do
          false
        end
      end

      def enable_discount?
        enable_discount
      end

      def disable_discount?
        !enable_discount?
      end

      if !self.method_defined?(:enable_change_price)
        define_method :enable_change_price do
          false
        end
      end

      def enable_change_price?
        enable_change_price
      end

      if !self.method_defined?(:category_ids)
        define_method :category_ids do
          []
        end
      end

      def category_names
      end

      def update_stock_quantity(line_item_quantity)
      end

      def update_sale_quantity(line_item_quantity)
      end

      def rollback_stock_quantity(line_item_quantity)
      end

      def to_line_itemable(options={})
        OrderService::LineItemable.new(self, options)
      end

      def to_stockables
        [self]
      end

    end
  end
end
