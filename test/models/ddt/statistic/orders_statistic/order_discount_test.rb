require 'test_helper'
require_relative '../concern/base_test'
module Ddt
  module Statistic
    module OrdersStatistic
      class OrderDiscountTest < TestCase::Base
        include Statistic::Concern::BaseTest
        attr_accessor :statistic

        def setup
          @statistic = Ddt::OrdersStatistic::OrderDiscount.new(
            shop: shop,
            accessible_branches: [branch],
            start_time: 2.minute.since,
            end_time: 2.hour.since,
            statistic_name: 'orders_statistic',
            request_path: '/fake/path'
          )
        end

      end
    end
  end
end

