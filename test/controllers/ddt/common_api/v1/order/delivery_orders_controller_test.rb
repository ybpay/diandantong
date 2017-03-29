require 'test_helper'
require_relative './base_order_controller_test'

module Ddt
  module CommonApi
    module V1
      module Order
        class DeliveryOrdersControllerTest < TestCase::Controller::CommonApi
          include V1::Order::BaseOrderControllerTest
          include V1::Order::BaseOrderChangeControllerTest

          def setup
            @order = example_delivery_order
          end
        end
      end
    end
  end
end
