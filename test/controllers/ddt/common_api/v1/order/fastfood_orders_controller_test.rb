require 'test_helper'
require_relative './base_order_controller_test'

module Ddt
  module CommonApi
    module V1
      module Order
        class FastfoodOrdersControllerTest < TestCase::Controller::CommonApi
          include V1::Order::BaseOrderControllerTest

          def setup
            @order = example_fastfood_order
          end
        end
      end
    end
  end
end
