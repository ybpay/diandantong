# encoding:utf-8
module Ddt
  class Notification
    module View
      class Email < Ddt::Notification::View::Base

        def render_order_placed
          subject = {
            account: "您的门店#{branch.name}又有新的订单#{order.number}来了，请赶紧处理哦",
            web_user: "您的订单#{order.number}已经提交, 请等待处理"
          }[target_type]
          [subject, body]
        end

        def render_order_confirmed
          subject = {
            account: "订单#{order.number}已经确认.",
            web_user: "您的订单#{order.number}已经确认."
          }[target_type]
          [subject, body]
        end

        def render_order_completed
          subject = {
            account: "订单#{order.number}已经完成。.",
            web_user: "您的订单#{order.number}已经完成。."
          }[target_type]
          [subject, body]
        end

        def render_order_canceled
          subject = {
            account: "订单#{order.number}已经取消。",
            web_user: "您的订单#{order.number}已经取消。",
          }[target_type]
          [subject, body]
        end

        def render_order_paid
          subject = {
            account: "订单#{order.number}已经完成支付。.",
            web_user: "您的订单#{order.number}已经完成支付。."
          }[target_type]
          [subject, body]
        end

        def render_order_change_append_itemable
          subject = {
            account: "订单#{order.number}有追加商品，请尽快处理。."
          }[target_type]
          [subject, body]
        end

        def render_order_change_delete_itemable
          subject = {
            account: "订单#{order.number}有删减商品，请尽快处理。."
          }[target_type]
          [subject, body]
        end

        def render_shipment_started
          subject = {
            web_user: "您的订单#{order.number}已经开始配送"
          }[target_type]
          [subject, body]
        end

        def render_shipment_shipped
          subject = {
            web_user: "您的订单#{order.number}已经配送完成"
          }[target_type]
          [subject, body]
        end

        private
        def body
          order.order_detail_in_text
        end
      end
    end
  end
end
