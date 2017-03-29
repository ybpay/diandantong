 # encoding:utf-8
module Ddt
  class Notification
    module View
      class Backend < Ddt::Notification::View::Base
        alias_method :account, :target

        def render_order_placed
          {
            type: event_type,
            title: "您有新的订单来了",
            content: "您的门店[#{branch.name}]又有新的订单了，订单号(#{order.number})，订单金额#{order.total}",
            link:   order.backend_show_path
          }
        end

        def render_order_confirmed
          {
            type: event_type,
            title: "您的订单已经确认",
            content: "您的门店[#{branch.name}]订单已确认了，订单号(#{order.number})",
            link:  order.backend_show_path
          }
        end

        def render_order_canceled
          {
            type: event_type,
            title: "订单已经取消",
            content: "您的门店[#{branch.name}]订单已取消，订单号(#{order.number})",
            link:  order.backend_show_path
          }
        end

        def render_order_paid
          {
            type: event_type,
            title: "订单已支付",
            content: "您的门店[#{branch.name}]的订单#{order.number}已经完成支付",
            link: order.backend_show_path
          }
        end

        def render_order_change_append_itemable
          {
            type: event_type,
            title: "订单有追加商品",
            content: "您的门店[#{branch.name}]的订单#{order.number}有追加商品",
            link: order.backend_show_path
          }
        end

        def render_order_change_delete_itemable
          {
            type: event_type,
            title: "订单有删减商品",
            content: "您的门店[#{branch.name}]的订单#{order.number}有删减商品",
            link: order.backend_show_path
          }
        end

        def render_order_hasten
          {
            type: event_type,
            title: "催单",
            content: order.hasten_message(track_from: event.track_from, line_item_id: event.line_item_id),
            link: order.backend_show_path
          }
        end

        def render_order_call_waiter
          {
            type: event_type,
            title: "呼叫服务员",
            content: order.call_waiter_message(event.service_name),
            link: order.backend_show_path
          }
        end

        def render_order_request_pay
          {
            type: event_type,
            title: "顾客请求买单",
            content: order.request_pay_message + "(支付方式: #{event.pay_method_name})",
            link: order.backend_show_path
          }
        end

        def render_table_changed
          {
            type: event_type,
            title: "换台消息",
            content: order_change_log.change_table_msg,
            link: '#'
          }
        end

        def render_table_cleared
          {
            type: event_type,
            title: "清台消息",
            content: table.name_with_zone,
            link: '#'
          }
        end

        def render_table_merged
          {
            type: event_type,
            title: "并台消息",
            content: order_change_log.merge_table_msg,
            link: '#'
          }
        end

        def render_table_move_itemable
          {
            type: event_type,
            title: "转菜消息",
            content: order_change_log.move_itemable_msg,
            link: '#'
          }
        end

        def render_table_opened
          {
            type: event_type,
            title: "开台台消息",
            content: table.name_with_zone,
            link: '#'
          }
        end

        def render_user_apply_vip
          {
            type: event_type,
            title: "申请会员消息",
            content: "您的平台，有新的会员申请",
            link: shop.backend_waiting_users_path
          }
        end

        def render_account_send_message
          {
            type: event_type,
            title: "系统消息",
            content: system_message.content,
            link: "#",
          }
        end

        def render_product_stock_empty
          {
              type: event_type,
              title: '产品估清消息',
              content: "门店#{branch.name}的产品#{variant.name_with_options_text}已估清，请及时处理",
              link: variant.backend_show_path
          }
        end

        def render_coupon_applying_refund
          {
            type: event_type,
            title: "#{base_coupon.coupon_type_name}申请退款消息",
            content: "#{base_coupon.coupon_type_name}: #{(base_coupon.abstract_coupon_version.name rescue '')} 申请退款, 请及时处理.",
            link: base_coupon.backend_show_path
          }
        end

        def render_coupon_cancel_applying_refund
          {
            type: event_type,
            title: "#{base_coupon.coupon_type_name}申请退款已取消",
            content: "{base_coupon.coupon_type_name}: #{(base_coupon.abstract_coupon_version.name rescue '')} 申请退款, 请及时处理.",
            link: base_coupon.backend_show_path
          }
        end

        def render_printer_notify_error
          {
              type: event_type,
              title: "打印机[#{printer.name}]出错",
              content: "请确认打印机[#{printer.name}]是否正常出单，若不能出单请尝试重启打印机.",
              link: printer.backend_show_path
          }
        end

        def render_printer_notify_not_working
          {
              type: event_type,
              title: "打印机[#{printer.name}]不出单, 最后出单时间为#{event.last_print_success_at}",
              content: "最后出单时间为#{event.last_print_success_at}, 请确认打印机[#{printer.name}]是否正常出单，若不能出单请尝试重启打印机. ",
              link: printer.backend_show_path
          }
        end

        private

      end
    end
  end
end
