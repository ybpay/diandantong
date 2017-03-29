module Ddt
  module OrderService
    class LineItem
      include OrderService::Concern::Base
      include OrderService::Concern::BelongsToOrder
      belongs_to :itemable, polymorphic: true, with_deleted: true
      delegate :enable_change_price, to: :itemable
      attr_accessor_with_dirty :id, :quantity, :note, :enjoy_vip_price, :enjoy_custom_price, :gift, :gift_reason,
                    :price, :vip_price, :original_price, :adjustment_total, :adjust_reason, :apportion_adjustment_total, :apportion_adjust_reason,
                    :product_name, :sku, :itemable_name, :unit_name, :category_names, :enable_discount,
                    :created_at, :updated_at, :change_price_at, :is_append, :deleted_at, :delete_by_admin, :not_actual_amount,
                    :price_bak # delete this if column price_bak is removed
      # subtract
      attr_accessor_with_dirty :is_subtract, :source_line_item_id, :subtract_quantity, :subtract_reason
      # move
      attr_accessor_with_dirty :is_moved, :is_from_move, :move_quantity
      get_with_shop_time_zone :created_at, :updated_at, :change_price_at
      boolean_method_for :is_append, :is_subtract, :enable_discount, :is_moved, :is_from_move, :gift, :enjoy_vip_price, :enjoy_custom_price
      validates :quantity, numericality: { only_integer: true }
      validates :price, numericality: { greater_than_or_equal_to: 0 }
      attr_accessor :order_change_log_id

      def initialize(params={})
        self.adjustment_total = 0
        self.adjust_reason = ""
        self.apportion_adjustment_total = 0
        self.apportion_adjust_reason = ""
        self.not_actual_amount = 0
        self.subtract_quantity = 0
        self.move_quantity = 0
        super(params.except(:line_item_trace_points))
        set_timestamps if new?
        init_for_new
        changes_applied if exists?
      end

      def subtotal
        self.price * self.active_quantity
      end
      alias_method :amount, :subtotal
      alias_method :total, :subtotal

      def subtotal_after_discount
        subtotal + adjustment_total + apportion_adjustment_total
      end

      def changed_values
        if new?
          litps = []
          unless is_subtract? || is_moved?
            if is_variant?
              litp = { itemable_type: "Ddt::Variant", itemable_id: itemable_id, name: itemable_name}
              quantity.times.each { litps << litp }
            elsif is_variant_package?
              litp = { itemable_type: "Ddt::VariantPackage", itemable_id: itemable_id, name: itemable_name}
              quantity.times.each { litps << litp }
            elsif is_combo_package?
              sub_litps = []
              itemable.each_item do |variant, quantity|
                litp = { itemable_type: "Ddt::Variant", itemable_id: variant.id, name: "[#{itemable.name}] #{variant.itemable_name}"}
                quantity.times { sub_litps << litp }
              end
              quantity.times { litps << sub_litps }
              litps.flatten!
            end
          end
          super.merge(line_item_trace_points: litps.map{|litp| litp.merge(created_at: current_time, updated_at: current_time)})
        else
          super
        end
      end

      concerning :CacheItemableInfo do
        def cache_itemable_info
          if itemable.present?
            [:product_name, :sku, :itemable_name, :category_names, :unit_name, :vip_price, :original_price, :price, :enable_discount].each do |method_name|
              self.send("#{method_name}=", itemable.send(method_name))
            end
          end
        end

        private
        def init_for_new
          if new? && !is_subtract?
            cache_itemable_info
            set_enjoy_vip_price
          end
        end
      end

      concerning :GiftPrice do

        def create_gift_price_adjustment
          if gift?
            amount = -(self.price * active_quantity)
            if amount != 0
              self.order.adjust(
                reason: :enjoy_gift_price,
                amount: amount,
                label: "赠菜(#{self.itemable_name}:#{-self.price})",
                operator: Ddt::Account.current,
                item_adjustments: [self.get_item_adjustment(amount)]
              )
            end
          end
        end

        def destroy_gift_price_adjustment
          self.order.adjustments.each do |a|

            if :enjoy_gift_price == a.reason.to_sym && a.item_adjustments.first.line_item_id == self.id
              if exists? && a.item_adjustments.first.line_item_id == self.id
                a.destroy
                break
              elsif a.item_adjustments.first.line_item_index == self.order.line_items.index(self)
                a.destroy
                break
              end
            end
          end
        end

        def update_gift_price_adjustment
          destroy_gift_price_adjustment
          create_gift_price_adjustment
        end

      end

      concerning :VipPrice do
        def set_enjoy_vip_price
          if enable_discount && !is_change_price? && !gift? && order.is_vip? && price != vip_price
            self.enjoy_vip_price = true
          end
        end

        def unset_enjoy_vip_price
          if !is_change_price? && !gift?
            self.enjoy_vip_price = false
          end
        end
      end


      def same_line_itemable?(line_itemable)
        self.itemable_type == line_itemable.itemable_type &&
        self.itemable_id   == line_itemable.itemable_id &&
        self.note          == line_itemable.note &&
        self.gift          == line_itemable.gift &&
        self.gift_reason   == line_itemable.gift_reason
      end

      def same_itemable?(itemable)
        self.itemable_type == itemable.itemable_type &&
        self.itemable_id   == itemable.itemable_id
      end

      concerning :AppendSubtract do
        def active?
          !is_subtract? && !is_moved? && active_quantity > 0
        end
        alias_method :can_delete?, :active?
        alias_method :can_subtract?, :active?
        alias_method :can_move?, :active?

        def active_quantity
          quantity - subtract_quantity - move_quantity
        end
      end

      alias_method :name, :itemable_name
      def name_with_note
        "#{self.name} #{self.note.present? ? "[#{self.note}]" : ""}"
      end

      def itemable_type_str
        self.itemable_type.demodulize.underscore
      end

      [:variant, :variant_package, :combo_package, :abstract_coupon_version, :recharge_product].each do |type_name|
        define_method "#{type_name}?" do
          self.itemable_type_str.to_sym == type_name
        end
        alias_method "is_#{type_name}?".to_sym, "#{type_name}?".to_sym
      end

      def groupon_version?
        self.itemable.class.name.demodulize.underscore == 'groupon_version'
      end
      alias_method :is_groupon_version?, :groupon_version?

      def voucher_version?
        self.itemable.class.name.demodulize.underscore == 'groupon_version'
      end
      alias_method :is_voucher_version?, :voucher_version?

      concerning :Print do
        # 该产品是否在（非全品打印机）的打印白名单上
        def in_white_list?(white_list_ids)
          case self.itemable_type
          when 'Ddt::Variant', 'Ddt::VariantPackage'
            white_list_ids.include? self.itemable.product_id
          when 'Ddt::ComboPackage'
            combo_package = self.itemable
            combo_package.each_item do |variant, quantity|
              return true if white_list_ids.include? variant.product_id
            end
            return false
          end
        end
      end

      concerning :ChangePrice do
        def change_price(new_price)
          if new_price == self.price
            self.update(price: new_price, enjoy_custom_price: false, change_price_at: nil)
          else
            self.update(price: new_price, enjoy_custom_price: true, change_price_at: current_time)
          end
        end

        def is_change_price
          self.change_price_at.present?
        end
        alias_method :is_change_price?, :is_change_price
      end

      concerning :ChangeWeight do
        def change_weight(new_weight)
          if self.is_variant_package?
            self.itemable.update(weight: new_weight)
            self.update(original_price: self.itemable.original_price, price: self.itemable.price, vip_price: self.itemable.vip_price, itemable_name: self.itemable.itemable_name)
          end
        end
      end

      concerning :StockSale do

        def update_sale_quantity
          self.itemable.update_sale_quantity(active_quantity)
        end

        def update_stock_quantity
          self.itemable.update_stock_quantity(active_quantity)
        end

        def rollback_stock_quantity
          self.itemable.rollback_stock_quantity(active_quantity)
        end
      end

      def line_itemable
        OrderService::LineItemable.new(itemable, quantity: active_quantity, note: note, gift: gift, gift_reason: gift_reason)
      end

      def to_line_itemable_options
        [:itemable_type, :itemable_id, :quantity, :note, :gift, :gift_reason].inject({}) do |options, key|
          options[key] = self.send(key)
          options
        end
      end

      concerning :AliasMethod do
        def item_name
          name
        end

        def item_price
          price
        end

        def item_quantity
          active_quantity
        end

        def item_note
          note
        end

        def item_subtotal
          subtotal
        end

        def item_subtotal_after_discount
          subtotal_after_discount
        end

        def line_item_id
          id
        end
      end

      concerning :ItemAdjustment do
        def get_item_adjustment(item_discount_amount, options={})
          if exists?
            OrderService::Adjustment.new(amount: item_discount_amount, line_item_id: id, is_apportion: options[:is_apportion])
          else
            OrderService::Adjustment.new(amount: item_discount_amount, line_item_index: order.line_items.index(self), is_apportion: options[:is_apportion])
          end
        end
      end

      def can_discount?
        ["", "privilege_discount", "vip_discount", "discount_plan"].include?(self.adjust_reason.to_s) && enable_discount?
      end

      def coupon_adjust?
        [:coupon].include?(self.adjust_reason.to_sym)
      end

      def promotion_adjust?
        [:promotion].include?(self.adjust_reason.to_sym)
      end

      def discount_adjust?
        [:privilege_discount, :vip_discount, :discount_plan].include?(self.adjust_reason.to_sym)
      end
    end
  end
end
