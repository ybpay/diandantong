require 'test_helper'
require_relative '../concern/base_test'
module Ddt
  module Statistic
    module UserStatistic
      class NewUserTest < TestCase::Base
        include Statistic::Concern::BaseTest
        attr_accessor :statistic

        def setup
          create_list(:vip_info, 2, shop: shop, vip_level: vip_level, created_at: 1.hour.since)
          @statistic = Ddt::UserStatistic::NewUser.new(
            shop: shop,
            accessible_branches: [branch],
            start_time: 2.minute.since,
            end_time: 2.hour.since,
            statistic_name: 'user_statistic',
            request_path: '/fake/path'
          )
        end

        def test_result
          body = statistic.body
          assert_equal 2, statistic.body[0][0]
        end

      end
    end
  end
end
