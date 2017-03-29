module Ddt
  class NotifyPayAfterPlacedWorker
    include Sidekiq::Worker

    def perform(order_id)
      order = Ddt::OrderService::Order::Delivery.find(order_id)
      if order && 'FromWechat' == order.track_from && order.is_pay_online? && order.is_not_paid?
        if order.user
          order.shop.notify_to(order.user, {
            title: "您刚下的外卖订单还未付款",
            description: "您于#{order.placed_at.strftime('%T')}下的订单还未付款，详情请点击本消息",
            url: order.weixin_show_url
          })
        end
      end
    end

  end
end
