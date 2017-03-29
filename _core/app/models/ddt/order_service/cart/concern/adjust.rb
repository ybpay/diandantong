module Ddt
  module OrderService
    module Cart
      module Concern
        module Adjust
          extend ActiveSupport::Concern
          included do
            attr_accessor :promotion_ids
          end

          def adjust(reason:, source: nil, amount: nil, label: nil, item_adjustments: [], operator: nil, need_apportion: false)
            label = source.try(:get_label_of_adjustment, self) || label || OrderService::Adjustment.reason_name(reason)
            amount = source.try(:compute_amount_of_adjustment, self) || amount
            item_adjustments = source.try(:get_item_adjustments, self) || item_adjustments
            return if amount == 0
            adjustment = OrderService::Adjustment.new(reason: reason, source: source, label: label, amount: amount, cart: self, operator: operator)
            if item_adjustments.blank? && (source.try(:need_apportion_adjustment_amount?) || need_apportion)
              items = self.line_items.active.sort_desc.select(&:enable_discount?)
              item_subtotal_sum = items.map(&:subtotal).sum
              if item_subtotal_sum > 0
                item_adjustments = items.map do |item|
                  item_adjustment_amount = (amount * (1.0 * item.subtotal / item_subtotal_sum)).round_to_floor(2)
                  item.get_item_adjustment(item_adjustment_amount, is_apportion: true)
                end
                rounding_diff_amount = (amount - item_adjustments.map(&:amount).sum).round(2)
                item_adjustments.first.amount += rounding_diff_amount if rounding_diff_amount != 0 && item_adjustments.present?
              end
            end
            adjustment.init_item_adjustments(item_adjustments)
            self.adjustments.push(adjustment)
            if reason == :promotion && source.present?
              self.promotion_ids ||= []
              self.promotion_ids << source.promotion_id
            end
            adjustment
          end

          def clear_promotion
            self.promotion_ids = []
            self.adjustments.promotion.destroy_all
          end

          private
          def add_promotion_relation_after_place(order_id)
            if self.promotion_ids.present?
              sql = []
              sql << "INSERT INTO ddt_promotions_orders ( order_id, promotion_id ) VALUES "
              sql << self.promotion_ids.uniq.map{|pid| "(#{order_id}, #{pid})"}.join(",")
              sql << ";"
              ActiveRecord::Base.connection.execute(sql.join)
            end
          end
        end
      end
    end
  end
end
