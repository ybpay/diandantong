require 'test_helper'
require_relative './base_order_controller_test'

module Ddt
  module CommonApi
    module V1
      module Order
        class ReservationOrdersControllerTest < TestCase::Controller::CommonApi
          include V1::Order::BaseOrderControllerTest

          def setup
            @order = example_reservation_order_prepay_for_order
          end
        end
      end
    end
  end
end
