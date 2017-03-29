module Ddt
  module OrderService
    module Order
      class Recharge < Order::Base
        has_many :recharge_refunds
        def after_complete_action
          apply_recharge
          self.vip_info.increment!(:recharge_times) if self.vip_info.present?
          super
        end

        def need_auto_confirm_after_pay?
          true
        end

        def need_auto_complete_after_pay?
          true
        end

        def evaluate_promotion?
          false
        end

        concerning :PrintRule do
          def need_notify_guest_printer_when_place?
            false
          end

          def need_notify_webpos_printer_when_paid?
            !self.is_local_printed?
          end
        end

        def pay_method_blacklist
          [:pay_on_arrive, :pay_on_receive, :vip_card_pay]
        end

        def recharge_refund_state_name
          self.recharge_refunds.first.try(:state_name)
        end

        def before_init_refund
          Ddt::RechargeRefund.init_refund(self)
          false if self.errors.present?
        end

        def total_extra_credits
          self.line_items.active.map{|item| item.itemable.extra_credits * item.active_quantity }.sum
        end

        def total_recharge_amount
          self.line_items.active.map{|item| item.itemable.recharge_amount * item.active_quantity }.sum
        end

        def total_cash_amount
          self.line_items.active.map{|item| item.itemable.price * item.active_quantity }.sum
        end

        def total_extra_amount
          self.line_items.active.map{|item| (item.itemable.recharge_amount - item.itemable.price) * item.active_quantity }.sum
        end

        private
        def apply_recharge
          options = {}
          options[:branch] = self.branch unless self.branch.is_abstract?
          options[:order] = self
          options[:note] = self.note
          options[:operator] = self.operator if self.operator.present?
          self.line_items.each do |line_item|
            line_item.quantity.times do
              self.vip_info.card_wallet.recharge_with_product(line_item.itemable, self.pay_method_names, options)
              self.vip_info.credits_wallet.get(line_item.itemable.extra_credits, note: "充值赠送", order: self) if line_item.itemable.extra_credits > 0
            end
          end
          # 充值后可用金额
          limited_amount = self.line_items.map{|line_item|
            line_item.itemable.recharge_amount - line_item.itemable.first_recharge_available_amount
          }.sum
          vip_info.update(first_recharge_at: Time.now, first_recharge_limited_amount: limited_amount)
          # 分享来源会员充值
          if vip_info.source_user.present?
            Promotion::Events::FromSharedUserRecharge.delay.create(base_user_id: vip_info.source_user_id)
          end
        end
      end
    end
  end
end
