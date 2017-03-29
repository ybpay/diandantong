module Ddt
  class Notification
    module Event
      module Order
        class Base < Ddt::NotificationEvent
          belongs_to :branch
          belongs_to_order
          attribute :order_id
          set_from :order, targets: [:terminal_id, :shop_id, :branch_id]
        end
      end
    end
  end
end
