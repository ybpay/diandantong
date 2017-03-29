require "test_helper"
require_relative "./base_test"
module Ddt
  module OrderService
    module Order
      class GrouponTest < TestCase::Base
        include OrderService::Order::BaseTest
        let(:itemable){ create :groupon_version, branch: branch, shop: shop }
        let(:order){ example_groupon_order }
      end
    end
  end
end