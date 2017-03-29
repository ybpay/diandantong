require "test_helper"
require_relative "./base_test"
module Ddt
  module OrderService
    module Cart
      class GrouponTest < TestCase::Base
        include OrderService::Cart::BaseTest
        let(:itemable){ create :groupon_version, branch: branch, shop: shop }
        let(:cart){ OrderService::Cart::Groupon.new(branch: branch) }
        let(:cart_with_pay_method){ OrderService::Cart::Groupon.new(branch: branch, pay_method: :pay_on_face) }
        let(:cart_class){ OrderService::Cart::Groupon }
      end
    end
  end
end