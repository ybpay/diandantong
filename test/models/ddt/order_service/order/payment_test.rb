require "test_helper"
require_relative "./base_test"
module Ddt
  module OrderService
    module Order
      class PaymentTest < TestCase::Base
        include OrderService::Order::BaseTest
        let(:itemable){ variant }
        let(:order){ example_payment_order }
      end
    end
  end
end