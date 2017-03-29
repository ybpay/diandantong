# encoding:utf-8
module Ddt
  class Notification
    module View
      class Weixin < Ddt::Notification::View::Base
        include Ddt::Color
        alias_method :user, :target

        def render_order_placed
          order_wrap("您的订单#{order.number}已经提交", green)
        end

        def render_order_confirmed
          order_wrap("您的订单#{order.number}已经确认", blue)
        end

        def render_order_canceled
          order_wrap("您的订单#{order.number}已经取消", red)
        end

        def render_order_completed
          order_wrap("您的订单#{order.number}已经完成", green)
        end

        def render_order_paid
          order_wrap("您的订单#{order.number}已经完成支付", green)
        end

        def render_order_started
          order_wrap("您的订单#{order.number}已经开始配送", blue)
        end

        def render_order_call_customer
          order_wrap("亲爱的#{order.food_number}号顾客, 请到配餐台取餐", green)
        end

        def render_order_change_delete_itemable
          line_items = order.line_items.by_log(order_change_log)
          names = line_items.map(&:name_with_note).join(',')
          order_wrap("您的订单#{order.number}有删减菜品：#{names}", blue)
        end

        def render_shipment_assigned
          order_wrap("您的订单#{order.number}已经指派给配送员#{order.shipment.delivery_man.name rescue nil}", blue)
        end

        def render_shipment_started
          order_wrap("您的订单#{order.number}已开始配送", blue)
        end

        def render_shipment_shipped
          order_wrap("您的订单#{order.number}已经配送完成", blue)
        end

        def render_coupon_applied
          coupon_wrap("您的一张#{coupon_name}已使用")
        end

        def render_coupon_expired
          coupon_wrap("您的一张#{coupon_name}已过期")
        end

        # {{first.DATA}}
        # 商户名称：{{keyword1.DATA}}
        # 兑换码：{{keyword2.DATA}}
        # 兑换内容：{{keyword3.DATA}}
        # 失效期：{{keyword4.DATA}}
        # {{remark.DATA}}
        def render_coupon_expiring
          data = {
            topcolor: red,
            first:    { color: black, value: "优惠券到期提醒"},
            keyword1: { color: black, value: base_coupon.shop.name},
            keyword2: { color: black, value: base_coupon.exchange_code.code},
            keyword3: { color: black, value: base_coupon.value_desc},
            keyword4: { color: black, value: base_coupon.expires_at.strftime("%F %T")},
            remark:   { color: black, value: "请您于有效期前凭兑换码到店兑换，防止过期无效"}
          }
          items = []
          items << "商户名称：#{base_coupon.shop.name}"
          items << "兑换内容：#{base_coupon.value_desc}"
          items << "兑换码: #{base_coupon.exchange_code.code}"
          items << "失效期： #{base_coupon.expires_at.strftime("%F %T")}"
          items << "请您于有效期前凭兑换码到店兑换，防止过期无效"
          {
            url: Ddt::LinkResource.new(shop: base_coupon.shop).base_coupon_whole_url(base_coupon),
            data: data,
            title: "优惠券到期提醒",
            description: items.join("\n")
          }
        end

        def render_coupon_get
          coupon_wrap("您获得了一张#{coupon_name}")
        end

        def render_coupon_refund
          coupon_wrap("您的一张#{coupon_name}已回退")
        end

        def render_queue_accepted
          queue_wrap("排号提醒: 编号#{guest_queue.guest_no}已经可以用餐了", red)
        end

        def render_queue_change
          queue_wrap("排号提醒: 还需等待#{guest_queue.guest_num_at_front}桌", blue)
        end

        def render_queue_enqueueing
          queue_wrap("排号提醒: 编号#{guest_queue.guest_no}已成功领号，您可以点击本消息提前点菜，节约等待时间哦", green)
        end

        def render_queue_notify
          queue_wrap("排号提醒: 编号#{guest_queue.guest_no}请您立即前往迎宾台", red)
        end

        def render_queue_past
          queue_wrap("排号过号提醒: 编号#{guest_queue.guest_no}已过号", red)
        end

        def render_queue_cancel
          queue_wrap("排号取消提醒: 编号#{guest_queue.guest_no}已取消", red)
        end

        def render_queue_binded
          queue_wrap("成功绑定微信排号#{guest_queue.guest_no}，现在起您可以实时接收排号进展通知了，还可以点击本消息立即使用微信进行预定菜 。", red)
        end

        def render_user_apply_vip
          {
            title: "会员申请已被接受",
            description: "我们已经收到您的会员申请，会尽快进行处理",
            url: ""
          }
        end

        def render_invitation_accepted
          {
            title: "您的邀请有新进展",
            description: "#{guest.nickname} 接受了您的邀请",
            url: order.invitation_show_url
          }
        end

        def render_invitation_rejected
          {
            title: "您的邀请有新进展",
            description: "#{guest.nickname} 拒绝了您的邀请",
            url: order.invitation_show_url
          }
        end


            # {{first.DATA}}
            # 时间：{{keyword1.DATA}}
            # 变更原因：{{keyword2.DATA}}
            # 变更金额：{{keyword3.DATA}}
            # {{remark.DATA}}
        def render_user_card_wallet_change
          data = {
            topcolor: red,
            first:    { color: black, value: "会员余额变动提醒"},
            keyword1: { color: black, value: wallet_log.created_at.strftime('%F %T')},
            keyword2: { color: black, value: wallet_log.reason_name},
            keyword3: { color: black, value: wallet_log.amount},
            remark:   { color: black, value: "余额: #{wallet_log.try(:balance)}"}
          }
          items = []
          items << "时间: #{wallet_log.created_at.strftime('%F %T')}"
          items << "变动原因: #{wallet_log.reason_name}"
          items << "变更金额： #{wallet_log.amount}"
          items << "余额: #{wallet_log.try(:balance)}"
          {
            url: Ddt::LinkResource.new(shop: user.shop).vip_info_whole_url,
            data: data,
            title: "会员余额变动提醒",
            description: items.join("\n")
          }
        end
            # {{first.DATA}}
            # 会员姓名：{{keyword1.DATA}}
            # 会员账号：{{keyword2.DATA}}
            # 积分变更：{{keyword3.DATA}}
            # 剩余积分：{{keyword4.DATA}}
            # {{remark.DATA}}
        def render_user_credits_wallet_change
          data = {
            topcolor: red,
            first:    { color: black, value: "积分余额变动提醒\n变更时间: #{wallet_log.created_at.strftime('%F %T')}\n变更原因: #{wallet_log.reason_name}"},
            keyword1: { color: black, value: (user.vip.name rescue "-")},
            keyword2: { color: black, value: (user.vip.vip_no rescue "-")},
            keyword3: { color: black, value: wallet_log.amount},
            keyword4: { color: black, value: wallet_log.wallet.amount},
            remark:   { color: black, value: ""}
          }
          items = []
          items << "时间: #{wallet_log.created_at.strftime('%F %T')}"
          items << "变更原因: #{wallet_log.reason_name}"
          items << "会员姓名: #{(user.vip.name rescue '-')}"
          items << "会员帐号: #{(user.vip.vip_no rescue '-')}"
          items << "积分变更: #{wallet_log.amount}"
          items << "剩余积分: #{wallet_log.try(:balance)}"
          {
            url: Ddt::LinkResource.new(shop: user.shop).vip_info_whole_url,
            data: data,
            title: "积分余额变动提醒",
            description: items.join("\n")
          }
        end



        def template_id_short
          config = Ddt::WeixinConfig.template_id_short
          event_type = self.event_type.to_s
          case event_type
          when "user_card_wallet_change"
            config.card
          when "user_credits_wallet_change"
            config.credits
          when "coupon_expiring"
            config.exchange_code
          else
            if event_type.start_with?("order") || event_type.start_with?("shipment")
              config.order
            elsif event_type.start_with?("queue")
              config.queue
            end
          end

        end

        # 将模板消息参数转为客服消息参数
        def to_customer_message_params(template_message_params)
          {
            title:       template_message_params[:title] || template_message_params[:data][:first][:value],
            description: template_message_params[:description] || template_message_params[:data][:remark][:value],
            url:         template_message_params[:url]
          }
        end

        private

          # 标题: 订单状态提醒
          # 详细内容
          #      {{first.DATA}}
          #      订单号：{{keyword1.DATA}}
          #      订单状态：{{keyword2.DATA}}
          #      时间：{{keyword3.DATA}}
          #      {{remark.DATA}}
        def order_wrap(title, topcolor)
          data = {
            topcolor: topcolor,
            first:    { color: black, value: title },
            keyword1: { color: black, value: order.number },
            keyword2: { color: black, value: order.state_name},
            keyword3: { color: black, value: order.placed_at.strftime('%F %T')},
            remark:   { color: black, value: order.order_detail_in_text(event_type: event_type, version: :weixin)}
          }
          { url: order.weixin_show_url, data: data }
        end

          # 标题: 排号通知
          # 详细内容
          #      {{first.DATA}}
          #      当前排号：{{keyword1.DATA}}
          #      取号时间：{{keyword2.DATA}}
          #      {{remark.DATA}}
        def queue_wrap(title, topcolor)
          queue_setting = guest_queue.queue_setting
          if guest_queue.queueing?
            desc = "门店名称：#{branch.name}\n排队号码：#{guest_queue.queue_setting.name} #{guest_queue.guest_no}\n前面等待：#{guest_queue.guest_num_at_front}桌\n排队状态：#{guest_queue.workflow_state_name}"
          elsif guest_queue.accepted?
            desc = "重要提醒：#{branch.name} 请您立即前往就餐\n\n排队号码：#{guest_queue.queue_setting.name} #{guest_queue.guest_no}"
          else
            desc = "您在#{branch.name}的排队状态更新为#{guest_queue.workflow_state_name}，如有疑问，请联系我们工作人员\n排队号码：#{guest_queue.queue_setting.name} #{guest_queue.guest_no}\n排队状态：#{guest_queue.workflow_state_name}"
          end
          data = {
            topcolor: topcolor,
            first:    { color: black, value: title},
            keyword1: { color: black, value: guest_queue.guest_no},
            keyword2: { color: black, value: guest_queue.created_at.strftime('%F %T')},
            remark:   { color: black, value: desc}
          }
          { url: guest_queue.weixin_view_url, data: data }
        end

        def coupon_name
          base_coupon.class.model_name.human
        end

        def coupon_wrap(title)
          {
            title: title,
            description: base_coupon.abstract_coupon_version.name,
            url: base_coupon.weixin_show_url
          }
        end

      end
    end
  end
end
