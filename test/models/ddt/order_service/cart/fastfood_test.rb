require "test_helper"
require_relative "./base_test"
module Ddt
  module OrderService
    module Cart
      class FastfoodTest < TestCase::Base
        include OrderService::Cart::BaseTest
        let(:itemable){ variant }
        let(:cart){ OrderService::Cart::Fastfood.new(branch: branch) }
        let(:cart_with_pay_method){ OrderService::Cart::Fastfood.new(branch: branch, pay_method: :pay_on_face) }
        let(:cart_class){ OrderService::Cart::Fastfood }

        def test_place_with_default_food_number
          cart.add(itemable)
          order = cart.place
          assert order.food_number.present?
        end
      end
    end
  end
end