module Ddt
  module OrderService
    module Cart
      class Recharge < Cart::Base
        def evaluate_promotion?
          false
        end

        def to_options
          super
        end

        def pay_method_blacklist
          [:pay_on_receive, :pay_on_arrive]
        end

        concerning :Validation do
          included do
            validate :check_item_count
          end
        end
      end
    end
  end
end