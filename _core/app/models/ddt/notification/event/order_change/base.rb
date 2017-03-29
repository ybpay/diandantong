module Ddt
  class Notification
    module Event
      module OrderChange
        class Base < Ddt::NotificationEvent
          belongs_to :branch
          belongs_to_order
          belongs_to_order_change_log
          attribute :order_id, :order_change_log_id
          set_from :order_change_log, targets: [:branch_id, :shop_id, :order]
        end
      end
    end
  end
end
