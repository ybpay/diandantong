module Ddt
  module OrderService
    module Order
      module Concern
        module CallWaiterTest
          extend ActiveSupport::Concern

          def test_call_waiter
            assert_change "order.last_call_waiter_at" do
              order.call_waiter("service_name")
            end
          end

          def test_call_waiter_message
            assert order.call_waiter_message("service_name").present?
          end

          def test_last_call_waiter_at_before_now_in_5_minutes
            travel_to 1.minute.ago do
              order.call_waiter("service_name")
            end
            assert order.last_call_waiter_at_before_now.present?
          end

          def test_last_call_waiter_at_before_now_out_5_minutes
            travel_to 6.minute.ago do
              order.call_waiter("service_name")
            end
            assert order.last_call_waiter_at_before_now.nil?
          end
        end
      end
    end
  end
end
