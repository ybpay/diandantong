module Ddt
  module OrderService
    module Order
      class Payment < Order::Base
        concerning :PrintRule do
          def need_notify_guest_printer_when_place?
            false
          end
        end

        def need_auto_confirm_after_place?
          true
        end

        def evaluate_promotion?
          false
        end

        def pay_method_blacklist
          [:pay_on_arrive, :pay_on_receive]
        end
      end
    end
  end
end
