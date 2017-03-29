module Ddt
  module OrderService
    module Cart
      module Concern
        module PayTest
          extend ActiveSupport::Concern
          def test_create_pay_item
            cart_with_pay_method.create_pay_item
            assert_equal cart_with_pay_method.pay_items.count, 1
          end

          def test_create_pay_item_with_0_amount
            cart_with_pay_method.stubs(:amount_for_pay).returns(0)
            pay_item = cart_with_pay_method.create_pay_item
            assert_equal 'paid', pay_item.state.to_s
          end
        end
      end
    end
  end
end