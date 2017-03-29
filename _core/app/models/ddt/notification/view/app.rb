# encoding:utf-8
module Ddt
  class Notification
    module View
      #
      # 推送消息格式
      # {
      #    title: 通知标题
      #    description: 通知内容
      #    custom_content: {
      #       id: 消息 id
      #       shop_id: 门店 id
      #       branch_id: 分店 id
      #       account_id: 当前通知的 account_id
      #       content: 消息内容
      #       event_type: 事件类型
      #       when: 通知时间
      #       category: 消息分组 (决定APP分组)
      #       order_type: 订单类型（仅订单消息）
      #       order_id: 订单ID （仅订单消息）
      #       guest_queue_id: （仅排号消息）
      #       queue_setting_id: （仅排号消息）
      #    }
      # }
      #
      # 推送的消息类型(event_type)：
      #   order_placed 下单
      #   order_confirmed 订单确认
      #   order_canceled 订单取消
      #   order_completed 订单完成
      #   order_paid 订单支付
      #
      #   order_call_waiter 呼叫服务员
      #
      #   queue_accepted
      #   queue_enqueuing
      #   queue_notify
      #   queue_past
      #
      class App < Ddt::Notification::View::Base
        # alias_method :account, :target

        def render_order_placed
          order_msg "新订单通知: #{order.extra_info} 订单号(#{order.number})，订单金额#{order.total}",
                    "新订单： #{order.extra_info} 订单号(#{order.number})，订单金额#{order.total} #{order.extra_desc}。【门店：#{branch.name}】",
                    order.display_type
        end

        def render_order_confirmed
          order_msg "订单确认通知: #{order.extra_info} 订单号(#{order.number})",
                    "订单已确认：#{order.extra_info} 订单号(#{order.number})  #{order.extra_desc}。【门店：#{branch.name}】",
                    order.display_type
        end

        def render_order_paid

          order_msg "订单支付通知:#{order.extra_info} 订单号(#{order.number})，支付金额#{order.amount_for_pay_in_currency}",
                    "订单已支付：#{order.extra_info} 订单号(#{order.number})  #{order.extra_desc}， 已经完成支付，支付金额#{order.amount_for_pay_in_currency}。【门店：#{branch.name}】",
                    'payment'
        end

        def render_order_canceled
          order_msg "订单取消通知： #{order.extra_info} 订单号(#{order.number})",
            "订单已取消：#{order.extra_info} 订单号(#{order.number})  #{order.extra_desc}，已经取消。操作人员：#{(event.order_change_log.operator_name rescue '')}【门店：#{branch.name}】",
            order.display_type
        end

        def render_order_change_append_itemable
          order_msg "订单追加商品通知 #{order.extra_info} 订单号(#{order.number})",
                    "#{order.extra_info} 订单号(#{order.number})  #{order.extra_desc}，有追加商品。#{(event.order_change_log.operator_name rescue '')}【门店：#{branch.name}】",
                    order.display_type
        end

        def render_order_change_delete_itemable
          order_msg "订单删减商品通知 #{order.extra_info} 订单号(#{order.number})",
                    "#{order.extra_info} 订单号(#{order.number}) #{order.extra_desc}有删减商品。操作人员：#{(event.order_change_log.operator_name rescue '')}【门店: #{branch.name}】",
                    order.display_type
        end

        def render_order_hasten
          order_msg "催单通知 #{order.extra_info} 订单号(#{order.number})",
                    order.hasten_message(track_from: event.track_from, line_item_id: event.line_item_id),
                    order.display_type
        end

        def render_order_call_waiter
          order_msg "呼叫服务员通知: #{order.extra_info} 订单号(#{order.number})",
                    order.call_waiter_message(event.service_name),
                    order.display_type
        end

        def render_order_request_pay
          order_msg "顾客请求买单: #{order.extra_info} 订单号(#{order.number})",
                     order.request_pay_message + "(支付方式: #{event.pay_method_name})",
                     order.display_type
        end

        def render_shipment_assigned
          if self.target.is_deliveryman?
            order_msg "订单指派通知: #{order.extra_info} 订单号(#{order.number})，已指派给你进行配送",
                      "订单指派通知: #{order.extra_info} 订单号(#{order.number})  #{order.extra_desc} 已指派给你进行配送",
                      order.display_type
          else
            order_msg "订单指派通知: 订单号(#{order.number}) #{order.extra_info} ,已指派给#{order.delivery_man_name}进行配送",
                      "订单指派通知: 订单号(#{order.number}) #{order.extra_info}  #{order.extra_desc} 已指派给#{order.delivery_man_name}进行配送",
                      order.display_type
          end
        end

        def render_shipment_unassigned
          order_msg "指派改变通知: #{order.extra_info} 订单号(#{order.number}), 已取消指派给你",
                    "指派改变通知: #{order.extra_info} 订单号(#{order.number})  #{order.extra_desc} 已取消指派给你",
                    order.display_type
        end

        def render_shipment_started
          order_msg "订单配送通知: #{order.extra_info} 订单号(#{order.number})已开始配送",
                    "订单配送通知: #{order.extra_info} 订单号(#{order.number})  #{order.extra_desc}已开始配送",
                    order.display_type
        end

        def render_shipment_shipped
          order_msg "订单配送通知: #{order.extra_info} 订单号(#{order.number})已配送完成",
                    "订单配送通知: #{order.extra_info} 订单号(#{order.number})  #{order.extra_desc}已配送完成",
                    order.display_type
        end

        def render_table_changed
          table_msg("换台通知: #{order.extra_info} 订单号(#{order.number}), 已从#{order_change_log.try(:from_table).try(:name_with_zone)}换到#{order_change_log.try(:to_table).try(:name_with_zone)}", order_change_log.try(:change_table_msg))
        end

        def render_table_merged
          table_msg("并台通知: #{order.extra_info} 订单号(#{order.number}), 已从#{order_change_log.from_table.name_with_zone}并到#{order_change_log.to_table.name_with_zone}", order_change_log.merge_table_msg)
        end

        def render_table_move_itemable
          table_msg("转菜通知: #{order.extra_info} 订单号(#{order.number})", order_change_log.move_itemable_msg)
        end

        def render_table_opened
          table_msg("开台通知: #{table.try(:name_with_zone)}", "开台 #{table.try(:name_with_zone)}", table_id: event.table_id)
        end

        def render_table_cleared
          table_msg("清台通知: #{table.try(:name_with_zone)}", "清台 #{table.try(:name_with_zone)}", table_id: event.table_id)
        end

        def render_queue_accepted
          queue_msg("排号通知: 编号#{guest_queue.guest_no}已入号用餐")
        end

        # def render_queue_change
        #   queue_msg("排号通知: 编号#{guest_queue.guest_no}排队状态有新的进展")
        # end

        def render_queue_enqueueing
          queue_msg("排号通知: 编号#{guest_queue.guest_no}进入排号队列")
        end

        def render_queue_notify
          queue_msg("排号通知: 编号#{guest_queue.guest_no}被呼叫")
        end

        def render_queue_past
          queue_msg("排号通知: 编号#{guest_queue.guest_no}已被服务员过号，请重新取号")
        end

        def render_queue_cancel
          queue_msg("排号通知: 编号#{guest_queue.guest_no}已被取消")
        end

        def render_queue_binded
          queue_msg("排号通知: 编号#{guest_queue.guest_no}已绑定微信")
        end


        def render_account_login
          msg = base_msg('账号登陆通知', '您的账号已登陆')
          msg[:custom_content].merge!(
            category: 'other',
            content: event.token_hash
          )
          msg
        end

        def render_account_send_message
          msg = base_msg('系统消息', system_message.message_type_name)
          msg[:custom_content].merge!(category: 'other', content: system_message.content)
          msg
        end

        def render_product_stock_empty
          msg = base_msg('产品估清通知', "产品#{variant.name_with_options_text}已估清")
          msg[:custom_content].merge!(
            category: 'other',
            content: "产品#{variant.name_with_options_text}已估清，请及时处理"
          )
          msg
        end


        private
        def base_msg(title, desc)
          {
              title: title,
              description: desc,
              custom_content: {
                  id: self.hash,
                  shop_id: self.shop.id,
                  account_id: self.target.id,
                  branch_id: (self.branch.id rescue nil),
                  event_type: event_type,
                  content: desc,
                  when: event.created_at_time
              }
          }
        end

        def order_msg(title, desc, category = 'order')
          msg = base_msg(title, desc)
          msg[:custom_content].merge!(
              {
                  category: category, # APP 的消息分组
                  order_id: order.id,
                  order_type: order.display_type
              })
          msg
        end

        def table_msg(title, desc, options = {})
          msg = base_msg(title, desc)

          msg[:custom_content].merge!({
              category: 'table',
            }).merge!(options)
          msg
        end

        def queue_msg(title)
          queue_setting = guest_queue.queue_setting
          desc = "#{title}。    [#{branch.name}]的排队队列[#{queue_setting.name}]长度变更为#{queue_setting.guest_queues.of_current_queue.length}"
          msg = base_msg title, desc
          msg[:custom_content].merge!(
            category: 'queue',
            queue_setting_id: queue_setting.id,
            guest_queue_id: guest_queue.id
          )
          msg
        end
      end
    end
  end
end
