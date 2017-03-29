# encoding: utf-8
module Ddt
  module OrderService
    module Order
      module Concern
        module Adjust
          extend ActiveSupport::Concern
          included do
          end

          def adjust(reason:, source: nil, amount: nil, label: nil, operator: nil, authorizer: nil, item_adjustments: [], need_apportion: false)
            label = source.try(:get_label_of_adjustment, self) || label || OrderService::Adjustment.reason_name(reason)
            amount = source.try(:compute_amount_of_adjustment, self) || amount

            # 优先使用改价源的分摊调整
            item_adjustments = source.try(:get_item_adjustments, self) || item_adjustments
            return if amount == 0

            # 创建调整并计算分摊
            adjustment = OrderService::Adjustment.new(reason: reason, source: source, label: label, amount: amount, order: self, operator: operator, authorizer: authorizer)
            if reason == :promotion
              add_promotion(source.promotion) if source.present?
            end

            if item_adjustments.blank? && (source.try(:need_apportion_adjustment_amount?) || need_apportion)
              items = self.line_items.active.enable_discount
              item_subtotal_sum = items.map(&:subtotal).sum
              if item_subtotal_sum > 0
                item_adjustments = items.calculate_item_adjustments(total: amount, is_apportion: true) do |subtotal|
                  (amount * (1.0 * subtotal / item_subtotal_sum)).round_to_floor(2)
                end
              end
            end

            # 复用已存在的调整。 合并以上计算的内容到已有的项目
            same_reason_destroyed_adjustment = adjustments.deleted.detect{|ad| ad.send("is_#{reason}?") && ad.source == source }
            if same_reason_destroyed_adjustment.present?
              same_reason_destroyed_adjustment.recover
              same_reason_destroyed_adjustment.update(source: source, label: label, amount: amount)
              same_reason_destroyed_adjustment.update_item_adjustments(item_adjustments)
              same_reason_destroyed_adjustment
            else
              adjustment.init_item_adjustments(item_adjustments)
              adjustments.push(adjustment)
              adjustment
            end
          end

          concerning :Privilege do
            def privilege_adjustment
              adjustments.active.privilege.first
            end
            [:privilege_discount, :privilege_reduction, :privilege_free].each do |name|
              define_method "#{name}_adjustment" do
                adjustments.send(name).first
              end
            end

            def privilege_adjustment_display
              adjustment = privilege_adjustment
              case adjustment.reason.to_sym
              when :privilege_discount
                get_privilege_discount
              when :privilege_reduction
                get_privilege_reduction
              when :privilege_free
              end
            end

            def get_privilege_discount
              adjustment = privilege_discount_adjustment
              "#{(1 - (- adjustment.amount / (item_total_for_discount - disable_discount_amount) )).round(2)}折" if adjustment.present? && item_total_for_discount > 0
            end

            def get_privilege_reduction
              adjustment = privilege_reduction_adjustment
              adjustment.amount_in_currency if adjustment.present?
            end

            def privilege_discount(discount, authorizer:, disable_discount_amount: 0)
              if can_change_total? && discount.present? && discount > 0 && discount < 1
                cancel_privilege_adjustment
                self.disable_discount_amount = disable_discount_amount
                amount = - ((item_total_for_discount - disable_discount_amount) * ( 1 - discount )).round(2)
                discount_display = discount.round(2)
                item_adjustments = line_items.active.can_discount.calculate_item_adjustments(total: amount) do |subtotal|
                  -(subtotal - (subtotal/item_total_for_discount)*disable_discount_amount) * (1 - discount).round(2) rescue 0
                end
                adjust(reason: :privilege_discount, label: "#{OrderService::Adjustment.reason_name(:privilege_discount)}#{discount_display}折", amount: amount, operator: operator, authorizer: authorizer, item_adjustments: item_adjustments)
              end
            end

            def privilege_reduction(reduce_amount, authorizer:)
              if can_change_total? && reduce_amount.present? && reduce_amount > 0 && reduce_amount <= total
                cancel_privilege_adjustment
                adjust(reason: :privilege_reduction, amount: -reduce_amount, operator: operator, authorizer: authorizer, need_apportion: true)
              end
            end

            def privilege_free(authorizer:)
              if can_change_total?
                cancel_privilege_adjustment
                adjust(reason: :privilege_free, amount: -item_total, operator: operator, authorizer: authorizer, need_apportion: true)
              end
            end

            def cancel_privilege_adjustment
              if can_change_total?
                adjustments.privilege.destroy_all
              end
            end
            alias_method :cancel_privilege_discount, :cancel_privilege_adjustment
            alias_method :cancel_privilege_reduction, :cancel_privilege_adjustment
            alias_method :cancel_privilege_free, :cancel_privilege_adjustment
          end

          concerning :Moling do
            # column: moling_amount
            def moling_present?
              self.moling_amount != 0
            end

            def moling_blank?
              self.moling_amount == 0
            end

            def moling
              if can_change_total?
                type = self.branch.is_moling_erase? ? :erase : :round
                moling_precision = self.branch.moling_precision
                ndigits = case moling_precision.to_sym
                          when :moling_shi; -1;
                          when :moling_yuan; 0;
                          when :moling_jiao; 1;
                          when :moling_fen;  2;
                          end
                moling_num = (self.total - MolingUtil.send(type, self.total, ndigits)).round(2)
                self.moling_amount -= moling_num
              end
            end

            def cancel_moling
              if can_change_total?
                self.moling_amount = 0
              end
            end
          end

          concerning :VipDiscount do
            def vip_discount_adjustment
              adjustments.active.vip_discount.first
            end

            def update_vip_discount_adjustment
              vip_discount_adjustment.try(:destroy)
              if vip_discount < 1.0
                discount_amount = (item_total_for_discount * (1 - vip_discount)).round(2)
                item_adjustments = line_items.active.select(&:can_discount?).map do |line_item|
                  amount = -line_item.subtotal * (1 - vip_discount).round(2)
                  line_item.get_item_adjustment(amount)
                end
                adjust(reason: :vip_discount, label: "会员#{(vip_discount * 10).round(1)}折", amount: -discount_amount, item_adjustments: item_adjustments) if discount_amount > 0
              end
            end
          end

          concerning :VipPrice do
            def vip_price_adjustment
              adjustments.active.enjoy_vip_price.first
            end

            def update_vip_price_adjustment
              vip_price_adjustment.try(:destroy)
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

          concerning :Coupon do
            def coupon_adjustment
              adjustments.coupon.first
            end

            def update_coupon_adjustment
              if coupon_adjustment.present? && coupon.present? && !coupon.satisfy?(self)
                rollback_coupon_adjustment
              end
            end

            def can_apply_coupon?(coupon)
              coupon.can_apply?(self)
            end

            def apply_coupon(coupon, authorizer:nil)
              if can_change_total? && can_apply_coupon?(coupon)
                transaction do
                  rollback_coupon_adjustment
                  self.coupon = coupon
                  adjust(reason: :coupon, source: coupon, operator: operator, authorizer: authorizer)
                  coupon.set_applied(self, operator)
                  update_total_and_save
                end
              end
            end

            def rollback_coupon
              if can_change_total?
                transaction do
                  rollback_coupon_adjustment
                  update_total_and_save
                end
              end
            end

            private
            def rollback_coupon_adjustment
              coupon_adjustment.try(:destroy)
              coupon.try(:rollback_coupon)
              self.coupon = nil
            end
          end

          concerning :Voucher do
            def voucher_adjustment
              adjustments.voucher.first
            end

            def can_apply_voucher?(voucher)
              voucher.can_apply?(self)
            end

            def apply_voucher(voucher, authorizer:)
              if can_apply_voucher?(voucher)
                transaction do
                  rollback_voucher_adjustment
                  self.voucher = voucher
                  adjust(reason: :voucher, source: voucher, operator: operator, authorizer: authorizer)
                  voucher.set_applied(self, operator)
                  update_total_and_save
                end
              end
            end

            def rollback_voucher
              transaction do
                rollback_voucher_adjustment
                update_total_and_save
              end
            end

            private
            def rollback_voucher_adjustment
              voucher_adjustment.try(:destroy)
              voucher.try(:rollback_voucher)
              self.voucher = nil
            end
          end

          concerning :DiscountPlan do
            def discount_plan_adjustment
              adjustments.active.discount_plan.first
            end

            def get_discount_plan
              adjustment = discount_plan_adjustment
              "#{adjustment.label} #{adjustment.amount}" if adjustment.present?
            end

            def add_discount_plan(discount_plan, authorizer: nil)
              if can_change_total? && discount_plan_adjustment.blank?
                adjust(reason: :discount_plan, source: discount_plan, operator: operator, authorizer: authorizer)
              end
            end

            def cancel_discount_plan
              if can_change_total?
                adjustments.discount_plan.destroy_all
              end
            end
          end

           def can_change_total?(need_errors: false)
            if need_errors
              self.errors[:base] << "该订单正在结算多种支付方式,不允许进行其他操作，" if multi_pay_item?
              self.errors[:base] << "该订单已结算,不能操作" if paid?
              self.errors.blank?
            else
              !multi_pay_item? && !paid?
            end
          end
        end
      end
    end
  end
end
