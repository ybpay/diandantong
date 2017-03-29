# encoding: utf-8
module Ddt
  class OrderCallWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 0, :queue => :critical

    def perform(order_id)
      Ddt::OrderCall.create_call(order_id)
    end

  end
end
