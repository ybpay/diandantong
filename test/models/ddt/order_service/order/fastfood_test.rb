require "test_helper"
require_relative "./base_test"
require_relative "./concern/call_waiter_test"
require_relative "./concern/hastenable_test"
module Ddt
  module OrderService
    module Order
      class FastfoodTest < TestCase::Base
        include OrderService::Order::BaseTest
        include OrderService::Order::Concern::CallWaiterTest
        include OrderService::Order::Concern::HastenableTest
        let(:itemable){ variant }
        let(:order){ example_fastfood_order }
      end
    end
  end
end