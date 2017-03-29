require "test_helper"
require_relative "base_cart_controller_test"
module Ddt
  module Weixin
    module Cart
      class FastfoodCartsControllerTest < TestCase::Controller::Weixin
        include Weixin::Cart::BaseCartControllerTest
        let(:itemable){ variant }
        let(:cart){ OrderService::Cart::Fastfood.new(branch: branch, user: user)}
        setup do
        end
      end
    end
  end
end