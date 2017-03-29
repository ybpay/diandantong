module Ddt
  module OrderService
    module Order
      module Concern
        module CallWaiter
          extend ActiveSupport::Concern
          included do
            has_many :order_call_waiters, class_name: 'Ddt::Notification::Event::Order::CallWaiter', foreign_key: :order_id
          end

          def call_waiter_message
            raise "Overwrite call_waiter_message in #{self.class}"
          end

          def call_waiter(service_name)
            self.order_ext.update(:last_call_waiter_at => Time.now)
            Notification::Event::Order::CallWaiter.create_and_send_notification(order: self, service_name: service_name)
          end

          def last_call_waiter_at
            self.order_ext.last_call_waiter_at
          end

          def last_call_waiter_at_time
            last_call_waiter_at.try(:to_i)
          end

          def last_call_waiter_at_before_now
            if last_call_waiter_at.present?
              seconds = (shop_time_now - last_call_waiter_at).to_i + 1
              seconds < 5.minutes.to_i ? seconds : nil
            end
          end
        end
      end
    end
  end
end
