require "test_helper"
module Ddt
  module OrderService
    module Api
      class BaseTest < TestCase::Base
        def test_mock
          OrderService::Config.stubs(:mock).returns(true)
          OrderService::Api::Mock::Order.stubs(:get).returns("mock")
          assert_equal "mock", OrderService::Api::Order.get(1)
        end

        def test_connect_with_error
          OrderService::Api::Order
          OrderService::Config.stubs(:mock).returns(true)
          assert_raise OrderService::Api::ConnectError do
            OrderService::Api::Order.connect('/', {}) do |host|
              URI.parse("#{host}").read
            end
          end
        end
      end
    end
  end
end