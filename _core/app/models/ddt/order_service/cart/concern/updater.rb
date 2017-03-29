module Ddt
  module OrderService
    module Cart
      module Concern
        module Updater
          extend ActiveSupport::Concern
          included do
          end

          def update_discount
            update_coupon_adjustment
            update_line_item_adjustment_total
            update_promotion
            update_line_item_adjustment_total
            update_line_item_price_adjustment
            update_vip_price_adjustment
            update_vip_discount_adjustment
            select_best_adjustment # 以前只有 vip_discount，故不需要选择 select_best_adjustment
            update_line_item_adjustment_total
            self
          end

          def update_promotion
            if evaluate_promotion?
              clear_promotion
              PromotionHandler::Cart.new(self).activate
            end
          end

          def update_line_item_price_adjustment
            line_items.each do |line_item|
              line_item.update_gift_price_adjustment
            end
          end

          def update_line_item_adjustment_total
            line_items.each do |line_item|
              line_item.adjustment_total = 0
              line_item.adjust_reason = ""
              line_item.apportion_adjustment_total = 0
              line_item.apportion_adjust_reason = ""
            end
            adjustments.each do |adjustment|
              if adjustment.item_adjustments.present?
                adjustment.item_adjustments.each do |item_adjustment|
                  line_item = line_items.to_a[item_adjustment.line_item_index]
                  if line_item.present?
                    if item_adjustment.is_apportion?
                      line_item.apportion_adjustment_total += item_adjustment.amount
                      line_item.apportion_adjust_reason += item_adjustment.reason.to_s
                    else
                      line_item.adjustment_total += item_adjustment.amount
                      line_item.adjust_reason += item_adjustment.reason.to_s
                    end
                  end
                end
              end
            end
          end

          concerning :Coupon do
            def update_coupon_adjustment
              adjustments.coupon.destroy_all
              if coupon.present? && coupon.can_apply?(self)
                adjust(reason: :coupon, source: coupon)
              end
            end

            def set_coupon(coupon)
              self.coupon = coupon
              update_coupon_adjustment
            end

            def clear_coupon
              set_coupon(nil)
            end
          end

          concerning :VipPrice do

            def update_vip_price_adjustment
              adjustments.enjoy_vip_price.destroy_all
              if self.vip_info_id
                amount = 0
                item_adjustments = []
                line_items.active.each do |line_item|
                  if line_item.enjoy_vip_price
                    vip_price_amount = (line_item.vip_price - line_item.price) * line_item.active_quantity
                    amount += vip_price_amount
                    item_adjustments << line_item.get_item_adjustment(vip_price_amount)
                  end
                end
                if item_adjustments.present?
                  adjust(
                    reason: :enjoy_vip_price,
                    amount: amount,
                    label: "会员价",
                    operator: Ddt::Account.current,
                    item_adjustments: item_adjustments
                  )
                end
              end
            end
          end

          concerning :VipDiscount do
            def update_vip_discount_adjustment
              adjustments.vip_discount.destroy_all
              if vip_discount < 1
                discount_amount = (item_total_for_discount * (1 - vip_discount)).round(2)
                item_adjustments = line_items.active.select(&:can_discount?).map do |line_item|
                  amount = -line_item.total * (1 - vip_discount).round(2)
                  line_item.get_item_adjustment(amount)
                end
                adjust(reason: :vip_discount, label: "会员#{(vip_discount * 10).round(1)}折", amount: -discount_amount, item_adjustments: item_adjustments) if discount_amount > 0
              end
            end
          end

          concerning :SelectBestAdjustment do
            def select_best_adjustment
              adjustments.need_best_select.each{|adjustment| adjustment.disabled = true }
              best_adjustment = adjustments.need_best_select.min_by {|it| it.amount}
              if best_adjustment.present?
                best_adjustment.disabled = false
                modify_line_item_flag(best_adjustment)
              end
              restore_line_item_flags
              adjustments.each do |adjustment|
                adjustment.destroy if adjustment.disabled?
              end
            end

            def modify_line_item_flag(adjustment)
              if adjustment.line_item_price_adjustment?
                adjustment.item_adjustments.each do |item_adjustment|
                  line_item = self.line_items.find_by_item_adjustment(item_adjustment)
                  if line_item.present?
                    case adjustment.reason.to_sym
                      when :enjoy_vip_price
                        line_item.enjoy_vip_price = true
                      when :enjoy_gift_price
                        line_item.gift = true
                    end
                  end
                end
              end
            end

            def restore_line_item_flags
              adjustments.each do |adjustment|
                if adjustment.disabled && adjustment.line_item_price_adjustment?
                  adjustment.item_adjustments.each do |item_adjustment|
                    line_item = self.line_items.find_by_item_adjustment(item_adjustment)
                    if line_item.present?
                      case adjustment.reason.to_sym
                        when :enjoy_vip_price
                          line_item.enjoy_vip_price = false
                        when :enjoy_gift_price
                          line_item.gift = false
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
