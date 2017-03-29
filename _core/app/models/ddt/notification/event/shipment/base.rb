module Ddt
  class Notification
    module Event
      module Shipment
        class Base < Ddt::NotificationEvent
          belongs_to :branch
          belongs_to_order
          attribute :order_id
          belongs_to :shipment
          set_from :shipment, targets: [:order_id, :branch_id, :shop_id]
        end
      end
    end
  end
end
