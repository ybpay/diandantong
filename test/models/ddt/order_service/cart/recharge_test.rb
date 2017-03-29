require "test_helper"
require_relative "./base_test"
module Ddt
  module OrderService
    module Cart
      class RechargeTest < TestCase::Base
        include OrderService::Cart::BaseTest
        let(:itemable){ create :recharge_product, shop: shop }
        let(:cart){ OrderService::Cart::Recharge.new(branch: branch) }
        let(:cart_with_pay_method){ OrderService::Cart::Recharge.new(branch: branch, pay_method: :pay_on_face) }
        let(:cart_class){ OrderService::Cart::Recharge }
      end
    end
  end
end