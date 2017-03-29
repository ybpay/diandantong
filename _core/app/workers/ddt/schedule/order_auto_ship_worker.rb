module Ddt
  module Schedule
    class OrderAutoShipWorker < Ddt::Schedule::Base
      sidekiq_options :retry => 0, :queue => :critical
      def perform
        branch_ids = Ddt::DeliverySetting.where(enable_auto_ship: true).pluck(:branch_id)
        Ddt::Shipment.where(branch_id: branch_ids, state: :shipping, shipping_at: 12.hours.ago..3.hours.ago).find_each do |shipment|
          shipment.ship
        end
      end
    end
  end
end
