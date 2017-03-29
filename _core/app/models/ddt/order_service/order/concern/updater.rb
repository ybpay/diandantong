module Ddt
  module OrderService
    module Order
      module Concern
        module Updater
          extend ActiveSupport::Concern
          included do
          end

          def update(params={})
            params.each do |key, value|
              self.send("#{key}=", value)
            end
          end

          def update_total
            self.item_count = self.line_items.item_count
            if self.item_total != self.line_items.item_total
              after_change_item_total_action
            end
            self.item_total = self.line_items.item_total
            update_coupon_adjustment
            update_line_item_adjustment_total
            update_promotion
            update_line_item_adjustment_total
            update_line_item_price_adjustment
            update_vip_price_adjustment
            update_vip_discount_adjustment
            select_best_adjustment
            update_line_item_adjustment_total
            self.adjustment_total = self.adjustments.adjustment_total
            self.tax_total = self.shop.calculate_tax(self.item_total)
            self.total = [item_total + tax_total + adjustment_total + extra_amount + moling_amount, 0].max
            self.amount_for_pay = self.get_amount_for_pay
            update_pay_item
            self
          end

          def update_total_and_save(touch: true)
            update_total
            save(touch: touch)
          end

          def computable_price
            self.line_items.item_total
          end

          def update_pay_info
            self.pay_item_state = self.pay_items.pay_item_state.to_s
            if self.pay_item_state_changed?
              if self.paid?
                self.paid_at = current_time
              else
                self.paid_at = nil
              end
            end
            self.multi_pay_item = self.pay_items.count > 1
            self.pay_item_total = self.pay_items.pay_item_total
            self.pay_method_names = self.pay_items.pay_method_names
            if self.pay_items.count == 1
              self.pay_method = self.pay_items.first.pay_method_name_sym.to_s
            else
              self.pay_method = nil
            end
          end

          def update_promotion(force: false)
            if self.evaluate_promotion? && (self.line_items.changed? || force)
              self.clear_promotions
              self.adjustments.promotion.destroy_all
              PromotionHandler::Order.new(self).activate
            end
          end

          def update_line_item_price_adjustment
            line_items.each do |line_item|
              if line_item.active?
                line_item.update_gift_price_adjustment
              else
                line_item.destroy_gift_price_adjustment
              end

            end
          end

          def update_line_item_adjustment_total
            line_items.each do |line_item|
              line_item.adjustment_total = 0
              line_item.adjust_reason = ""
              line_item.apportion_adjustment_total = 0
              line_item.apportion_adjust_reason = ""
            end
            adjustments.active.each do |adjustment|
              if adjustment.item_adjustments.present?
                adjustment.item_adjustments.each do |item_adjustment|
                  if item_adjustment.line_item_id.present?
                    line_item = line_items.find(item_adjustment.line_item_id)
                  else
                    line_item = line_items.to_a[item_adjustment.line_item_index]
                  end
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

          def update_pay_items_not_actual_amount
            pay_items.each do |pay_item|
              pay_item.not_actual_amount = pay_item.get_not_actual_amount
            end
            save
          end

          def update_line_item_not_actual_amount
            not_actual_amount = self.pay_items.map(&:not_actual_amount).sum.round(2)
            self.line_items.inactive.each do |item|
              item.not_actual_amount = 0
            end
            items = self.line_items.active.sort_desc
            item_total = items.map(&:subtotal).sum
            if item_total > 0
              items.each do |item|
                item.not_actual_amount = (not_actual_amount * item.subtotal / item_total).round_to_floor(2)
              end
              rounding_diff_amount = (not_actual_amount - items.map(&:not_actual_amount).sum).round(2)
              items.first.not_actual_amount += rounding_diff_amount if rounding_diff_amount != 0 && items.present?
            end
          end

          def update_combo_package_item_adjustments
            combo_package_line_items = self.line_items.active.select(&:is_combo_package?)
            combo_package_line_items.each do |line_item|
              Ddt::ComboPackageItem.set_adjustments(line_item)
            end
          end

          def select_best_adjustment
            adjustments.need_best_select.each{|adjustment| adjustment.disabled = true }
            best_adjustment = adjustments.need_best_select.min_by {|it| it.amount}
            if best_adjustment.present?
              best_adjustment.disabled = false
              modify_line_item_flag(best_adjustment)
            end
            restore_line_item_flags
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
