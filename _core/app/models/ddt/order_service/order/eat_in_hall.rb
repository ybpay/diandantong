module Ddt
  module OrderService
    module Order
      class EatInHall < Order::Base
        include OrderService::Order::Concern::Hastenable
        include OrderService::Order::Concern::CallWaiter
        belongs_to :table, with_discarded: true
        belongs_to_order name: :related_order

        def after_place_action
          table.order(self)
          self.order_ext.update!(ban_selfpay: table.ban_selfpay)
          table.destroy_merge_itemables
          # user 和 wifiuser 用的同名方法clear_pre_order_itemables，但定义的时候 user 是 pre_order, wifiuser 是 wifi_order
          self.user.clear_pre_order_itemables(self.branch) if self.user.present?
          super
        end

        def after_cancel_action
          table.cancel if table && table.current_order?(self)
          super
        end

        def after_complete_action
          table.clear if table && table.current_order?(self)
          super
        end

        def after_change_item_total_action
          if table.current_order?(self) && table.item_total != self.line_items.item_total
            table.update_attribute(:item_total, self.line_items.item_total)
          end
        end

        def extra_info
           "桌台 #{self.table_name_with_zone}"
        end

        def extra_desc
          if self.waiter.present?
            "点菜员：#{self.waiter_name}"
          else
            nil
          end
        end

        def after_pay_action
          if table.current_order?(self)
            table.pay
            if branch.eat_in_hall_setting.auto_clear_table?
              TableClearWorker.perform_in(30.seconds, self.table_id, self.id)
            end
          end
          super
        end

        def after_anti_settlement
          table.anti_settlement(self) if table.current_order_id.blank? || table.current_order?(self) || !table.active?
        end

        def after_append
          table.touch
        end

        def need_auto_confirm_after_place?
          s = branch.eat_in_hall_setting
          (is_FromWebpos? || is_FromApp?) ||
          ( is_FromWechat? && !branch.eat_in_hall_setting.is_pay_before? && (
            s.is_confirm_auto? ||
            (s.is_confirm_by_distance? && !branch.is_distance_limited?(self))
          ))
        end

        def need_auto_confirm_after_pay?
          true
        end

        def can_append_itemable?(need_errors: false)
          if need_errors
            self.errors[:base] << "该订单已完成或已结束,不能加减菜" unless active?
            self.errors[:base] << "该订单已支付,不能加减菜" unless is_not_paid?
            self.errors[:base] << "该订单已拉消费单，不能加减菜" if self.table.is_check_outing?
            self.errors[:base] << "该订单正在结算,不能加减菜" if multi_pay_item?
            self.errors[:base] << "该订单已使用折扣方案,不能加减菜,请先取消折扣方案" if discount_plan_adjustment.present?
            self.errors[:base] << "该订单已使用权限折扣,不能加减菜,请先取消折扣" if privilege_discount_adjustment.present?
            self.errors[:base] << "该订单已使用权限减免,不能加减菜,请先取消权限减免" if privilege_reduction_adjustment.present?
            self.errors[:base] << "该订单已使用权限免单,不能加减菜,请先取消权限免单" if privilege_free_adjustment.present?
            self.errors[:base] << "该订单已使用积分抵扣,不能加减菜,请先取消积分抵扣" if credits_deduction.present?
            self.errors[:base] << "该订单已使用优惠券,不能加减菜,请先取消优惠券" if coupon.present?
            self.errors.blank?
          else
            active? && is_not_paid? && !self.table.is_check_outing? && !multi_pay_item? && !discount_plan_adjustment.present? && !privilege_discount_adjustment.present?
          end
        end
        alias_method :can_subtract_itemable?, :can_append_itemable?
        alias_method :can_delete_itemable?, :can_append_itemable?
        alias_method :can_move_itemable?, :can_append_itemable?

        def displayer
          OrderDisplay::EatInHall.new(self)
        end

        def table_name_with_zone
          "#{table_zone_name}-#{table_name}"
        end

        concerning :Modified do
          def modified_at
            [modify_time(updated_at), modify_time(order_ext.try(:updated_at)), modify_time(last_hasten_at), modify_time(last_call_waiter_at)].max
          end
        end

        concerning :PrintRule do
          def guest_printers
            self.branch.printers.use_in_guest.active
          end

          def need_notify_guest_printer_when_place?
            if branch.eat_in_hall_setting.is_pay_before? && is_FromWechat?
              # (开启了预付款模式)扫码堂点不打印
              false
            else
              super && branch.print_setting.is_webpos_print_eatinhall_order_when_place?
            end
          end

          def need_notify_webpos_printer_when_paid?
            !is_local_printed?
          end
        end

        def need_auto_complete_after_pay?
          # 涉及到反结，如果订单完成是无法反结的
          false
        end

        concerning :ChangeMergeTable do
          def change_table(to_table)
            if self.table.ordered? && to_table.idle?
              transaction do
                add_change_log(:change_table, from_table: self.table, to_table: to_table)
                to_table.order(self)
                self.table.cancel
                self.table_id        = to_table.id
                self.table_name      = to_table.name
                self.table_zone_name = to_table.table_zone.name
                self.save
              end
              send_change_table_notification
              true
            else
              self.errors[:base] << "换台桌台不是空闲状态，不能换台." unless to_table.idle?
              self.errors[:base] << "当前桌台不能换台." unless self.table.ordered?
              false
            end
          end

          def merge_table(to_table)
            if self.table.ordered? && to_table.ordered?
              transaction do
                from_order = self
                from_table = self.table
                to_order = to_table.current_order
                to_order.operator = self.operator
                to_table.update(guest_num: from_table.guest_num.to_i + to_table.guest_num.to_i)
                from_table.cancel
                from_order.reload_line_item_trace_points
                to_order.reload_line_item_trace_points
                [:line_items, :line_item_trace_points, :order_change_logs].each do |items|
                  from_order.send(items).each do |item|
                    item.order = to_order
                    to_order.send(items).push(item)
                  end
                  from_order.send("#{items}=", [])
                end
                from_order.merged
                from_order.add_change_log(:merge_table, from_table: from_table, to_table: to_table, from_order_id: from_order.id, to_order_id: to_order.id)
                to_order.add_change_log(:merge_table, from_table: from_table, to_table: to_table, from_order_id: from_order.id, to_order_id: to_order.id)
                from_order.adjustments.each(&:destroy)
                from_order.adjustment_total = 0
                from_order.update_total
                to_order.update_total
                OrderService::Order::Base.batch_update(to_order, from_order)
              end
              reload
              send_merge_table_notification
              true
            else
              self.errors[:base] << "当前订单所在桌台没有正在用餐的订单，不允许并台." unless to_table.ordered?
              self.errors[:base] << "目标桌台不能并台." unless self.table.ordered?
              false
            end
          end

          private
          def send_change_table_notification
            change_log = self.order_change_logs.change_table.last
            Notification::Event::Table::Changed.create_and_send_notification(order_change_log: change_log)
          end

          def send_merge_table_notification
            change_log = self.order_change_logs.merge_table.last
            Notification::Event::Table::Merged.create_and_send_notification(order_change_log: change_log)
          end
        end

        concerning :MoveItemable do
          def move_itemable(to_table, moveables)
            moveables = [moveables] if moveables.is_a?(OrderService::Moveable)
            if self.table.ordered? && to_table.ordered? && self.table_id != to_table.id && can_subtract_itemable? && moveables.count > 0
              transaction do
                from_order = self
                from_table = self.table
                to_order = to_table.current_order
                to_order.operator = self.operator
                moveables.each do |moveable|
                  moveable.line_item.move_quantity += moveable.quantity
                  moved_line_item = OrderService::LineItem.new(moveable.to_options)
                  from_order.line_items.push(moved_line_item)
                  from_move_line_item = OrderService::LineItem.new(moveable.to_target_options(to_order))
                  to_order.line_items.push(from_move_line_item)
                end
                cancel_line_item_trace_points(moveables)
                from_order.add_change_log(:move_itemable, from_table: from_table, to_table: to_table, from_order_id: from_order.id, to_order_id: to_order.id)
                to_order.add_change_log(:move_itemable, from_table: from_table, to_table: to_table, from_order_id: from_order.id, to_order_id: to_order.id)
                from_order.update_total
                to_order.update_total
                to_table.touch
                from_table.touch
                OrderService::Order::Base.batch_update(to_order, from_order)
              end
              reload
              send_move_itemable_notification
            else
              self.errors[:base] << "当前订单所在桌台没有正在用餐的订单，不允许转菜." unless to_table.ordered?
              self.errors[:base] << "目标桌台不能转菜." unless self.table.ordered?
              false
            end
          end

          private
          def send_move_itemable_notification
            change_log = self.order_change_logs.move_itemable.last
            Notification::Event::Table::MoveItemable.create_and_send_notification(order_change_log: change_log)
          end
        end

        concerning :BindReservationOrder do
          def bind_reservation_order(order)
            self.errors[:base] << '不能绑定非预订订单' unless order.is_reservation?
            self.errors[:base] << '只能绑定预订订座的预订订单' unless order.is_reservation? && order.is_prepay_for_table?
            self.errors[:base] << '不能绑定已取消的预订订单' if order.canceled?
            self.errors[:base] << '已经绑定过预订订单' unless self.related_order.blank?
            self.errors[:base] << '该预订订单已经被绑定' unless order.related_order.blank?
            if self.errors.blank?
              transaction do
                if order.is_paid?
                  self.adjust(reason: :prepay_for_reservation_table, amount: -order.get_amount_for_pay)
                end
                self.update(related_order: order)
                order.update(related_order: self)
                self.update_total
                self.total_changed
                OrderService::Order::Base.batch_update(self, order)
              end
              order.reload
              order.confirm if order.can_confirm?
              order.complete if order.can_complete?
            end
          end
        end

        concerning :BanSelfpay do
          def ban_selfpay
            order_ext.ban_selfpay rescue false
          end

          def request_pay(pay_method_name)
            if is_not_paid?
              Notification::Event::Order::RequestPay.create_and_send_notification(order: self, pay_method_name: pay_method_name)
            end
          end

          def allow_selfpay
            if order_ext.present?
              order_ext.update!(ban_selfpay: false)
            end
          end

          def request_pay_message
            "桌台: #{self.try(:table).try(:name_with_zone)}，请求买单, 请前往处理. "
          end
        end

        concerning :ValueChanged do
          def total_changed
            table.touch(:updated_at) if table.current_order_id == self.id
          end
        end

        concerning :Message do
          def hasten_extra_message
            "#{self.table_name_with_zone} 已等待了, #{self.time_since_placed_at}"
          end

          def call_waiter_message(service_name)
            "#{self.table_name_with_zone} 呼叫服务员 #{service_name}"
          end
        end

        def update_guest_num(guest_num)
          if active? && guest_num > 0
            transaction do
              self.guest_num = guest_num
              self.table.update_guest_num(guest_num)
              self.save
            end
          end
        end

        def pay_method_blacklist
          [:pay_on_arrive, :pay_on_receive]
        end
      end
    end
  end
end
