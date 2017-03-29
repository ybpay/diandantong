 # encoding:utf-8
module Ddt
  class Notification
    module View
      class Webpos < Ddt::Notification::View::Base
        alias_method :account, :target

        def render_order_placed
          return if account.no_concern_order?
          messages = []
          messages << table_notification if order.is_eat_in_hall?
          messages << notificaiton_msg(title: "新单", content: order_short_info)
          messages << { type: 'NEW_ORDER_NOTIFICATION', order_id: order.id }
          if order.is_FromWechat? && branch.eat_in_hall_setting.is_confirm_by_distance? && branch.is_distance_limited?(order)
            messages << { type: 'NEW_DISTANCE_LIMITED_ORDER', order_id: order.id, content: order_short_info }
          end
          messages
        end

        def render_order_confirmed
          return if account.no_concern_order?
          messages = []
          if account.is_cook?
            # messages << cook_msg(order, "订单 (#{order.number}) 有菜品需要炒, 点击查看新增菜品", true) if account.concern_in_confirm(order).present?
          elsif can_receive_all_cook_msg?
            messages << cook_msg(order, "订单 (#{order.number}) 有菜品需要炒, 点击查看新增菜品", true)
          else
            messages << notificaiton_msg(title: "订单确认", content: order_short_info)
          end
          messages
        end

        def render_order_canceled
          return if account.no_concern_order?
          messages = []
          if account.is_cook?
            # messages << cook_msg(order, "订单 (#{order.number}) 已取消, 点击更新菜品列表") if account.concern_in_cancel(order).present?
          elsif can_receive_all_cook_msg?
            messages << cook_msg(order, "订单 (#{order.number}) 已取消, 点击更新菜品列表")
          else
            messages << table_notification if order.is_eat_in_hall?
            messages << notificaiton_msg(title: "订单取消", content: order_short_info)
          end
          messages
        end

        def render_order_paid
          return if account.no_concern_order?
          messages = []
          messages << { type: 'PAY_SUCCESS', order_id: order.id, branch_id: order.branch_id, order_number: order.number, table_name: order.try(:table).try(:name), table_id: order.try(:table_id), is_fast_food: order.is_fastfood?, order_type: order.type_str}
          messages << notificaiton_msg(title: "订单支付完成", content: order_short_info)
          messages << table_notification if order.is_eat_in_hall?
          messages
        end

        def render_order_change_append_itemable
          return if account.no_concern_order?
          messages = []
          if account.is_cook?
            # messages << cook_msg(order, "订单 (#{order.number}) 有追加商品, 点击查看新增菜品") if order.is_confirmed? && account.concern_in_append(order).present?
          elsif can_receive_all_cook_msg?
            messages << cook_msg(order, "订单 (#{order.number}) 有追加商品, 点击查看新增菜品")
          else
            messages << notificaiton_msg(title: "加菜", content: order_short_info)
          end
          messages << table_notification if order.is_eat_in_hall?
          messages
        end

        def render_order_change_delete_itemable
          return if account.no_concern_order?
          messages = []
          if account.is_cook?
            # messages << cook_msg(order, "订单 (#{order.number}) 有删减商品, 点击更新菜品列表") if account.concern_in_delete(order).present?
          elsif can_receive_all_cook_msg?
            messages << cook_msg(order, "订单 (#{order.number}) 有删减商品, 点击更新菜品列表")
          else
            messages << notificaiton_msg(title: "退菜", content: order_short_info)
          end
          messages << table_notification if order.is_eat_in_hall?
          messages
        end

        def render_order_call_waiter
          return if account.no_concern_order?
          messages = []
          messages << notificaiton_msg(title: "呼叫服务员", content: order.call_waiter_message(event.service_name))
          messages << { type: 'CALL_WAITER_MESSAGE', content: order.call_waiter_message(event.service_name), created_at: event.created_at_time.to_i}
          messages
        end

        def render_order_request_pay
          return if account.no_concern_order?
          notificaiton_msg(title: "顾客请求买单", content: order.request_pay_message + "(支付方式: #{event.pay_method_name})")
        end

        def render_order_hasten
          return if account.no_concern_order?
          notificaiton_msg(title: "催单", content: order.hasten_message(track_from: event.track_from, line_item_id: event.line_item_id))
        end

        def render_table_changed
          return if account.no_concern_order?
          messages = []
          messages << notificaiton_msg(title: "换台", content: order_change_log.change_table_msg)
          messages << table_notification
          messages
        end

        def render_table_merged
          return if account.no_concern_order?
          messages = []
          messages << notificaiton_msg(title: "并台", content: order_change_log.merge_table_msg)
          messages << table_notification
          messages
        end

        def render_table_move_itemable
          return if account.no_concern_order?
          messages = []
          messages << notificaiton_msg(title: "转菜", content: order_change_log.move_itemable_msg)
          messages << table_notification
          messages
        end

        def render_table_cleared
          return if account.no_concern_order?
          messages = []
          messages << notificaiton_msg(title: "清台", content: table.name_with_zone)
          messages << table_notification
          messages
        end

        def render_table_opened
          return if account.no_concern_order?
          messages = []
          content = "#{table.name_with_zone}, 已开台"
          messages << notificaiton_msg(title: "开台", content: content)
          messages << table_notification
          messages
        end

        def render_table_check_out
          return if account.no_concern_order?
          messages = []
          messages << { type: 'TABLE_CHECK_OUT', terminal_id: event.terminal_id, table_id: table.id}
          messages
        end

        def render_table_cancel_check_out
          return if account.no_concern_order?
          messages = []
          messages << { type: 'TABLE_CANCEL_CHECK_OUT', terminal_id: event.terminal_id, table_id: table.id}
          messages
        end

        def render_product_stock_empty
          return if account.no_concern_order?
          notificaiton_msg(title: '估清', content: variant.name_with_options_text)
        end

        [:render_queue_accepted, :render_queue_cancel, :render_queue_enqueueing, :render_queue_past, :render_queue_binded].each do |method_name|
          define_method method_name do
            {
              terminal_id: event.terminal_id,
              type: 'QUEUE_STATE_CHANGE',
              queue_states: branch.queue_states_json,
              guest_num_at_front: guest_queue.guest_num_at_front,
              queue_setting_id: guest_queue.queue_setting_id
            }
          end
        end

        #================================================
        # 打印机通知
        #================================================

        def render_printer_notify_error
          notificaiton_msg(
              printer_name: printer.name,
              printer_code: printer.number,
              title: "门店[#{printer.branch.name}]打印机[#{printer.name}]出错",
              content: "请确认打印机[#{printer.name}]状态，尝试重启打印机.",
          )
        end

        def render_printer_notify_not_working
          notificaiton_msg(
              printer_name: printer.name,
              printer_code: printer.number,
              title: "门店[#{printer.branch.name}]打印机[#{printer.name}]不出单，最后出单时间为#{event.last_print_success_at}",
              content: "最后出单时间为#{event.last_print_success_at}, 请确认打印机[#{printer.name}]状态，尝试重启打印机."
          )
        end

        #================================================
        # 开班/交班
        #================================================

        def render_shift_opened
          notificaiton_msg(
              type: 'SHIFT_STATE_CHANGED',
              title: '门店开班了',
              content: '门店开班了，15秒后将自动刷新'
          )
        end

        def render_shift_closed
          notificaiton_msg(
              type: 'SHIFT_STATE_CHANGED',
              title: '门店交班了',
              content: '门店交班了,15秒后将自动刷新'
          )
        end


        private

        def can_receive_all_cook_msg?
          account.is_chef? || account.is_boss?
        end

        def order_short_info
          "#{order.table.try(:name_with_zone) if order.is_eat_in_hall? }#{order.food_number if order.is_fastfood?} #{order.number}"
        end

        def cook_msg(order, notification_content, is_confirm=false)
          if is_confirm
            # 之前下的所有菜品，可能通过追加
            change_log_ids = order.order_change_logs.place_and_append.map{|log| log.id}
          else
            change_log_ids = [order.order_change_logs.last_log.id]
          end
          {type: 'COOK_NOTIFICATION', content: notification_content, order_number: order.number, change_log_ids: change_log_ids}
        end

        def notificaiton_msg(options={})
          {
            type: 'NOTIFICATION',
            event_type: event_type,
            created_at: event.created_at_time,
            branch_id: branch.try(:id),
            terminal_id: event.terminal_id
          }.merge!(options)
        end

        def table_notification
          { branch_id: branch.try(:id), type: 'TABLE_NOTIFICATION', event_type: event_type }
        end

      end
    end
  end
end
