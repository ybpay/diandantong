#encoding: utf-8
module Ddt
  module Schedule
    class CheckNewOrderWorker < Ddt::Schedule::Base
      def perform
        OrderService::Orders.where(state: :pending, placed_at: 15.minutes.ago..3.minutes.ago).each do |order|
          msg = {
            type: 'NOTIFICATION',
            event_type: "check_new_order",
            created_at: Time.now,
            branch_id: order.branch_id,
            title: "订单未处理",
            content: "您的#{order.number}订单已经#{((Time.now - order.placed_at)/60).floor}分钟没有处理"
          }
          accounts = order.all_managers
          accounts.each do |account|
            WebposChannel.broadcast_to(account, msg)
          end
        end
        OrderService::Orders.where(state: :pending, placed_at: 25.minutes.ago..15.minutes.ago).each do |order|
          if order.order_calls.count == 0
            Ddt::OrderCall.create_call(order.id)
          end
        end
      end
    end
  end
end
