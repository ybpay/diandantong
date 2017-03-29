require "test_helper"
require_relative "base_cart_controller_test"
module Ddt
  module Weixin
    module Cart
      class RechargeCartsControllerTest < TestCase::Controller::Weixin
        include Weixin::Cart::BaseCartControllerTest
        let(:itemable){ create :recharge_product, shop: shop }
        let(:cart){ OrderService::Cart::Recharge.new(branch: branch, user: user)}
        setup do
        end
      end
    end
  end
end