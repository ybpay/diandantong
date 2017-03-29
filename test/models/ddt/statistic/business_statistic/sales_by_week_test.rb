require 'test_helper'
require_relative '../concern/base_test'
module Ddt
  module Statistic
    module BusinessStatistic
      class SalesByWeekTest < TestCase::Base
        include Statistic::Concern::BaseTest
        attr_accessor :statistic

        def setup
          @statistic = Ddt::BusinessStatistic::SalesByWeek.new(
            shop: shop,
            accessible_branches: [branch],
            start_time: 3.month.ago,
            end_time: 2.hour.since,
            statistic_name: 'business_statistic',
            request_path: '/fake/path'
          )
        end

      end
    end
  end
end
