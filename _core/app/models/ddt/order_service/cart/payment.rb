module Ddt
  module OrderService
    module Cart
      class Payment < Cart::Base
        attr_accessor :payment_price
        def init_info(params={})
          @payment_price = params.fetch(:payment_price, 0).to_f
          adjust(reason: :payment_price, amount: @payment_price) if @payment_price > 0
        end

        def evaluate_promotion?
          false
        end

        def to_options
          super
        end

        def update_payment_price(new_price)
          self.payment_price = new_price
          self.adjustments.payment_price.destroy_all
          adjust(reason: :payment_price, amount: payment_price) if payment_price > 0
        end

        def pay_method_blacklist
          [:pay_on_receive, :pay_on_arrive]
        end

        concerning :Validation do
          included do
            validate :check_payment_price
          end

          def check_payment_price
            self.errors[:base] << "买单金额必须大于0" if self.payment_price <= 0
          end
        end
      end
    end
  end
end