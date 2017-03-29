module Ddt
  module OrderService
    class Adjustment
      include OrderService::Concern::Base
      include OrderService::Concern::BelongsToOrder
      belongs_to :operator, class_name: "Ddt::Account"
      belongs_to :authorizer, class_name: "Ddt::Account"
      belongs_to :source, polymorphic: true
      acts_as_type :reason, [:promotion, :reservation_table_price, :coupon, :voucher, :credits_deduction, :card_deduction, :privilege_discount, :privilege_reduction, :privilege_free, :moling, :payment_price, :prepay_for_reservation_table, :prepay_for_reservation_order, :enjoy_vip_price, :enjoy_gift_price, :vip_discount, :other, :discount_plan],
                            %w[优惠促销 预订桌台订金 优惠券 代金券 积分抵扣 余额抵扣 权限折扣 权限减免 权限免单 抹零 买单金额 订座预付 预订预付 会员价 赠送价 会员折扣 改价 折扣方案]
      attr_accessor_with_dirty :id, :reason, :label, :amount, :created_at, :updated_at, :deleted_at, :parent_id, :line_item_id, :disabled, :is_apportion
      boolean_method_for :disabled, :is_apportion
      attr_accessor :item_adjustments
      attr_accessor :line_item_index
      def initialize(params={})
        self.disabled = false
        super
        set_timestamps if new?
        changes_applied if self.exists?
      end

      def active?
        !disabled?
      end

      def need_best_select?
        if branch.share_multi_promotion
          false
        else
          [:privilege_discount, :enjoy_vip_price, :vip_discount, :discount_plan].include?(self.reason.to_sym)
        end
      end

      def line_item_price_adjustment?
        [:enjoy_vip_price, :enjoy_gift_price].include?(self.reason.to_sym)
      end

      def privilege?
        [:privilege_discount, :privilege_reduction, :privilege_free].include?(self.reason.to_sym)
      end

      def discount?
        # [:promotion, :coupon, :voucher, :credits_deduction, :card_deduction, :privilege_discount, :privilege_reduction, :privilege_free, :moling, :vip_discount, :other, :discount_plan]
        !not_discount?
      end

      def not_discount?
        [:reservation_table_price, :payment_price, :prepay_for_reservation_table, :prepay_for_reservation_order].include?(self.reason.to_sym)
      end

      def self.discount_reasons
        [
          :privilege_discount,
          :privilege_reduction,
          :privilege_free,
          :coupon,
          :voucher,
          :promotion,
          :enjoy_gift_price,
          :enjoy_vip_price,
          :vip_discount,
          :credits_deduction,
          :card_deduction,
          :discount_plan,
          :other
        ]
      end

      concerning :ItemAdjustment do
        included do
          def item_adjustments=(array)
            @item_adjustments = (Array === array ? OrderService::Collection::Adjustments.new(array) : array)
          end

          def init_item_adjustments(items)
            items.map do |item|
              [:reason, :source_type, :source_id, :label, :order, :operator, :authorizer].each do |key|
                item.send("#{key}=", self.send(key))
              end
              item
            end
            self.item_adjustments = items
          end

          def update_item_adjustments(items)
            items.each do |item|
              pre_item = self.item_adjustments.deleted.detect{|pre_item| pre_item.line_item_id == item.line_item_id }
              if pre_item.present?
                pre_item.recover
                pre_item.update(label: label, amount: item.amount)
              else
                [:reason, :source_type, :source_id, :label, :order, :operator, :authorizer].each do |key|
                  item.send("#{key}=", self.send(key))
                end
                self.item_adjustments.push(item)
              end
            end
          end

          def parent?
            !sub?
          end

          def sub?
            line_item_id.present? || line_item_index.present?
          end

          def destroy
            if self.new?
              self.delete
            else
              self._destroy = true
              if parent?
                self.item_adjustments.each do |item|
                  if item.new?
                    self.item_adjustments.delete(item)
                  else
                    item._destroy = true
                  end
                end
              end
            end
          end

          def changed?
            if parent?
              super || self.item_adjustments.changed?
            else
              super
            end
          end

          def changed_values
            if parent?
              super.merge(item_adjustments: item_adjustments.map{|item| item.changed_values.merge(line_item_index: item.line_item_index)})
            else
              super
            end
          end

          def apply_change(changes)
            if parent?
              self.item_adjustments.apply_changes(changes[:item_adjustments])
              super(changes.except(:item_adjustments))
            else
              if exists?
                if self.id == changes[:id]
                  self.created_at = changes[:created_at]
                  self.updated_at = changes[:updated_at]
                  self.parent_id = changes[:parent_id]
                  self.line_item_id = changes[:line_item_id]
                end
              else
                self.id = changes[:id]
                self.created_at = changes[:created_at]
                self.updated_at = changes[:updated_at]
                self.parent_id = changes[:parent_id]
                self.line_item_id = changes[:line_item_id]
              end
              changes_applied
            end
          end
        end
      end
    end
  end
end
