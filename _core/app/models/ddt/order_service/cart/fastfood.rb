module Ddt
  module OrderService
    module Cart
      class Fastfood < Cart::Base
        attr_accessor :food_number
        def init_info(params={})
          @food_number = params.fetch(:food_number, nil)
        end

        def number=(new_number)
          super
          self.food_number = new_number[-4..-1] if self.food_number.blank?
        end

        def to_options
          super.merge(
            food_number: food_number,
          )
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