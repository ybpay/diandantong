require "test_helper"
module Ddt
  class TableTest < TestCase::Base
    def test_counter_cache_in_table_zone
      skip
    end

    def test_open
      assert_change %W(table.state table.last_opened_at table.guest_num) do
        table.open(5)
      end
    end

    def test_order
      order = example_eat_in_hall_order
      assert_change %W(another_table.current_order_id another_table.guest_num) do
        another_table.order(order)
      end
    end
  end
end