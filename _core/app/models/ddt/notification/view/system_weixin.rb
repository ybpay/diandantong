# encoding:utf-8
module Ddt
  class Notification
    module View
      class SystemWeixin < Ddt::Notification::View::Base
        include Ddt::Color
        alias_method :account, :target
        def render_order_placed
          wrap("#{order.branch.name}又有新的订单了", red)
        end

        def render_order_confirmed
          wrap("#{order.branch.name}订单#{order.number}已经确认", green)
        end

        def render_order_canceled
          wrap("#{order.branch.name}订单#{order.number}已经取消", red)
        end

        def render_order_paid
          wrap("#{order.branch.name}订单#{order.number}已经支付", green)
        end

        def render_order_hasten
          wrap(order.hasten_message(track_from: event.track_from, line_item_id: event.line_item_id), red)
        end

        def render_order_call_waiter
           wrap(order.call_waiter_message(event.service_name), red)
        end

        def render_shipment_assigned
          if account.is_boss?
            wrap("订单指派消息： 订单(#{order.number})已指派给#{order.delivery_man_name}进行配送", blue)
          elsif account.is_deliveryman?
            wrap("订单指派消息： 订单(#{order.number})已指派给你进行配送", orange)
          end
        end

        def render_shipment_unassigned
          wrap("指派改变消息： 订单(#{order.number})已取消指派给你", orange)
        end

        def render_shipment_started
          wrap("订单配送消息: 订单(#{order.number})已开始配送", blue)
        end

        def render_shipment_shipped
          wrap("订单配送消息: 订单(#{order.number})已配送完成", blue)
        end

        def render_table_changed
          wrap(order_change_log.change_table_msg, blue)
        end

        def render_table_merged
          wrap(order_change_log.merge_table_msg, blue)
        end

        def render_table_move_itemable
          wrap(order_change_log.move_itemable_msg, blue)
        end

        def render_table_opened
          wrap("开台：#{table.name_with_zone}", blue)
        end

        def render_table_cleared
          wrap("清台：#{table.name_with_zone}", blue)
        end

        def render_coupon_applying_refund
          wrap("申请退款: #{(base_coupon.abstract_coupon_version.name rescue '')}", blue)
        end

        def render_coupon_cancel_applying_refund
          wrap("取消申请退款: #{(base_coupon.abstract_coupon_version.name rescue '')}", blue)
        end

        # def render_user_apply_vip
        #   return nil
        #   # 这里需要申请一个处理其他消息的模板
        #   #wrap("申请会员消息: 您的平台，有新的会员申请, 请赶紧处理", blue)
        # end

        # def render_product_stock_empty
        #   # need template
        #   # wrap("估清：#{variant.name_with_options_text}", red)
        #   return nil
        # end

        def render_account_send_message
          if system_message.is_exception?
            {
              template_id: exception_template_id,
              url: "#",
              data: {
                topcolor:  RED,
                first:     { color: black, value: "系统异常信息" },
                keyword1:  { color: black, value: "异常信息" },
                keyword2:  { color: black, value: system_message.created_at.strftime("%F %T") },
                keyword3:  { color: black, value: "" },
                remark:    { color: black, value: system_message.content },
              }
            }
          end
        end

        private
        def wrap(title, topcolor)
          data = {
            topcolor:       topcolor,
            first:         { color: black, value: title},
            tradeDateTime: { color: black, value: order.placed_at.strftime('%F %T')},
            orderType:     { color: black, value: order.type_name},
            customerInfo:  { color: black, value: order.try(:user).try(:to_label)},
            orderItemName: { color: black, value: '合计'},
            orderItemData: { color: black, value: order.total_in_currency},
            remark:        { color: black, value: order.order_detail_in_text(event_type: event_type, version: :system_weixin)}
          }
          {template_id: template_id, url: order.system_weixin_show_url, data: data}
        end

        def template_id
          if shop.is_custom_system_weixin_notification
            # 自定义订单模板id
            shop.custom_system_weixin_template_id
          else
            # 点单通服务号后台设置的订单模板id
            Ddt::WeixinConfig.template_id.order
          end
        end

        def exception_template_id
          Ddt::WeixinConfig.template_id.exception
        end

        def exception_wrap(title, content)

        end
      end
    end
  end
end
