require "test_helper"
module Ddt
  module OrderService
    class LitpTest < TestCase::Base
      let(:order){ example_eat_in_hall_order}
      def test_litp_find
        order
        litp = OrderService::Litps.last
        assert_equal litp.state, "pending"
        assert_equal litp.order_id, order.id
        order.reload_line_item_trace_points
        litp_id = order.line_item_trace_points.first.id
        litp = OrderService::Litps.find(litp_id)
        assert_equal litp.order_id, order.id
      end

      def test_state_change
        order
        litp = OrderService::Litps.last
        assert_equal litp.state, "pending"
        litp.confirm
        assert_equal litp.state, "confirmed"
        litp.complete
        assert_equal litp.state, "completed"
        litp.cancel
        assert_equal litp.state, "canceled"
      end
    end
  end
end