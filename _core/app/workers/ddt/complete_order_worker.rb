module Ddt
  class CompleteOrderWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 10, :queue => :default

    def perform(order_id, batch)
      order = Ddt::OrderService::Orders.find(order_id)
      order.ignore_notification = true if batch
      order.complete if order.can_complete?
    end
  end
end
