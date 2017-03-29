require "test_helper"
require_relative "./base_test"
module Ddt
  module OrderService
    module Cart
      class PaymentTest < TestCase::Base
        include OrderService::Cart::BaseTest
        let(:itemable){ variant }
        let(:cart){ OrderService::Cart::Payment.new(branch: branch, payment_price: 100) }
        let(:cart_with_pay_method){ OrderService::Cart::Payment.new(branch: branch, pay_method: :pay_on_face) }
        let(:cart_class){ OrderService::Cart::Payment }

        def test_init_with_payment_price_has_adjustment
          assert_equal 1, cart.adjustments.payment_price.count
        end

        def test_check_payment_price
          cart = OrderService::Cart::Payment.new(branch: branch, payment_price: -1)
          cart.check_payment_price
          assert cart.errors.present?
        end
      end
    end
  end
end