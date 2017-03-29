require "test_helper"
require_relative "base_cart_controller_test"
module Ddt
  module Weixin
    module Cart
      class GrouponCartsControllerTest < TestCase::Controller::Weixin
        include Weixin::Cart::BaseCartControllerTest
        let(:itemable){ create(:groupon_version, shop: shop, branch: branch) }
        let(:cart){ OrderService::Cart::Groupon.new(branch: branch, user: user)}
        setup do
        end
      end
    end
  end
end