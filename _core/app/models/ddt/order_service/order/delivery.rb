module Ddt
  module OrderService
    module Order
      class Delivery < Order::Base
        include OrderService::Order::Concern::Hastenable
        acts_as_type :shipment_state, [:pending, :shipping, :shipped, :canceled], %W(待处理 送货中 已送达 已取消)
        has_one :shipment
        delegate :delivery_man, :assign_delivery_man?, to: :shipment
        delegate :name, to: :delivery_man, prefix: true, allow_nil: true

        def delivery_date_str
          self.delivery_date.try(:strftime, "%F")
        end

        def extra_amount
          shipment_total
        end

        def displayer
          OrderDisplay::Delivery.new(self)
        end

        def extra_info
          "#{self.delivery_name}-#{self.delivery_phone}"
        end

        def extra_desc

        end

        def after_place_action
          Ddt::NotifyPayAfterPlacedWorker.perform_in(5.minutes, self.id)
          super
        end

        def after_complete_action
          self.shipment.ship if self.shipment.can_ship?
          self.shipment_state = shipment.state
          super
        end

        def after_cancel_action
          self.shipment.cancel if self.shipment.can_cancel?
          self.shipment_state = shipment.state
          super
        end

        def after_ship_action
          complete if can_complete? && need_auto_complete_after_ship?
        end

        def update_shipment_state
          self.shipment_state = shipment.state
          if self.is_shipped? && can_complete? && need_auto_complete_after_ship?
            complete
          else
            self.save
          end
        end

        def need_auto_confirm_after_place?
          (is_FromWebpos? || is_FromApp?) || branch.is_auto_confirm?
        end

        def need_auto_confirm_after_pay?
          is_FromWechat? && is_pay_online?
        end

        def need_auto_complete_after_pay?
          is_shipped? && branch.is_auto_complete_delivery_order?
        end

        def need_auto_complete_after_ship?
          paid? && branch.is_auto_complete_delivery_order?
        end

        def can_append_itemable?(need_errors: false)
          if need_errors
            self.errors[:base] << "该订单已完成或已结束,不能加减菜" unless active?
            self.errors[:base] << "该订单已支付,不能加减菜"       unless is_not_paid?
            self.errors[:base] << "该订单不是来自收银端,不能加减菜" unless is_FromWebpos?
            self.errors.blank?
          else
            active? && is_not_paid? && is_FromWebpos?
          end
        end
        alias_method :can_subtract_itemable?, :can_append_itemable?

        def hasten_extra_message
          "地址：#{self.delivery_address}"
        end

        concerning :Modified do
          def modified_at
            [modify_time(updated_at), modify_time(last_hasten_at)].max
          end
        end

        concerning :PrintRule do
          def need_notify_guest_printer_when_place?
            super && not_need_pay_online?
          end

          def need_notify_webpos_printer_when_paid?
            !self.is_local_printed?
          end
        end

        def default_pay_method
          :pay_on_receive
        end

        def assign_delivery_man(delivery_man_id)
          shipment.assign_delivery_man(delivery_man_id)
          self.update(delivery_man_id: delivery_man_id)
          save(touch: true)
        end

        def pay_method_blacklist
          [:pay_on_arrive]
        end

        [:start, :ship, :cancel].each do |action|
          define_method "#{action}_shipment" do
            self.shipment.send("#{action}!")
            self.update_shipment_state
          end
        end

      end
    end
  end
end
