require "test_helper"
module Ddt
  module OrderService
    module Api
      class ResultTest < TestCase::Base
        def test_initialize
          body = {status: 200, data: {}}.to_json
          result = OrderService::Api::Result.new(body)
          assert result.is_status_ok?
        end

        def test_initialize_with_error_status
          body = {status: 201, data: {}}.to_json
          assert_raise OrderService::Api::ResultError do
            OrderService::Api::Result.new(body)
          end
        end

        def test_initialize_with_error_format
          body = "<html>400</html>"
          assert_raise OrderService::Api::DecodeError do
            OrderService::Api::Result.new(body)
          end
        end
      end
    end
  end
end