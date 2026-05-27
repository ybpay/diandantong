# frozen_string_literal: true

module Ddt
  module PushService
    class << self
      def notify(user, title:, body:, data: {})
        channels = user.push_channels.active
        channels.each do |channel|
          case channel.os_type
          when 'android' then push_to_jpush(channel, title, body, data)
          when 'ios'     then push_to_apns(channel, title, body, data)
          end
        end
      end
    end

    class KitchenNotify
      def self.call(order)
        branch = order.branch
        accounts = branch.accounts.on_duty
        accounts.each do |account|
          PushService.notify(
            account,
            title: "新订单 #{order.number}",
            body: order.kitchen_summary,
            data: { order_id: order.id, action: 'new_order' }
          )
        end
      end
    end

    class CustomerNotify
      def self.order_confirmed(order)
        notify_customer(order, "订单已确认", "您的订单 #{order.number} 已被确认，正在准备中")
      end

      def self.order_cancelled(order)
        notify_customer(order, "订单已取消", "您的订单 #{order.number} 已被取消")
      end

      def self.order_completed(order)
        notify_customer(order, "订单已完成", "您的订单 #{order.number} 已完成，感谢您的光临")
      end

      def self.delivery_started(order)
        notify_customer(order, "配送中", "您的订单 #{order.number} 正在配送中")
      end

      private

      def self.notify_customer(order, title, body)
        return unless order.user

        PushService.notify(
          order.user,
          title: title,
          body: body,
          data: { order_id: order.id }
        )

        send_wechat_template(order, title, body) if order.user.wechat?
      end

      def self.send_wechat_template(order, title, body)
        wechat_account = order.shop.primary_wechat_account
        return unless wechat_account

        WechatTemplateSender.call(
          account: wechat_account,
          user: order.user,
          template_id: fetch_template_id(title),
          data: build_template_data(order, title, body)
        )
      end

      def self.fetch_template_id(title)
        case title
        when /确认/ then 'order_confirmed'
        when /取消/ then 'order_cancelled'
        when /完成/ then 'order_completed'
        when /配送/ then 'delivery_started'
        else 'order_notification'
        end
      end

      def self.build_template_data(order, title, body)
        {
          first: { value: title },
          keyword1: { value: order.number },
          keyword2: { value: order.total.to_s },
          keyword3: { value: Time.current.strftime('%Y-%m-%d %H:%M') },
          remark: { value: body }
        }
      end
    end

    private

    def push_to_jpush(channel, title, body, data)
      jpush_client = Ddt::JPushClient.new
      jpush_client.push(
        registration_id: channel.j_push_channel_id,
        title: title,
        body: body,
        extras: data
      )
    end

    def push_to_apns(channel, title, body, data)
      # APNS push implementation
    end

    class WechatTemplateSender
      def self.call(account:, user:, template_id:, data:)
        return unless user.open_id.present?

        Ddt::WeixinApi.send_template_message(
          access_token: account.access_token,
          touser: user.open_id,
          template_id: template_id,
          data: data
        )
      end
    end
  end
end
