module Ddt
  class CompleteOrderAfterShiftCloseWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 2, :queue => :default

    def perform(shift_id)
      shift = Ddt::Shift.find(shift_id)
      order_ids = Ddt::OrderService::Api::Mock::Model::Order.where({
          branch_id: shift.branch_id,
          type: %W[Ddt::EatInHallOrder Ddt::FastfoodOrder],
          state: :confirmed,
          pay_item_state: :paid,
          paid_at: shift.created_at..shift.closed_at
        }).pluck(:id)
      order_ids.each do |order_id|
        Ddt::CompleteOrderWorker.perform_in(1.minute, order_id, true)
      end
    end
  end
end
