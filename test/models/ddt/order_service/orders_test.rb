require "test_helper"
module Ddt
  module OrderService
    class OrdersTest < TestCase::Base
      concerning :Query do
        def test_scope
          assert_equal OrderService::Orders.by_state(:pending).query_params[:state_eq], :pending
          assert_equal OrderService::Orders.by_state(nil).query_params[:state_eq], nil
          assert OrderService::Orders.by_placed_at(1.day.ago, Time.now).query_params.has_key?(:placed_at_gt)
          assert OrderService::Orders.by_placed_at(1.day.ago, Time.now).query_params.has_key?(:placed_at_lt)
          assert !OrderService::Orders.by_placed_at(nil, nil).query_params.has_key?(:placed_at_gt)
        end

        def test_where
          assert_equal OrderService::Orders.where(id: 1).query_params[:id_eq], 1
          assert_equal OrderService::Orders.where(id: [1,2]).query_params[:id_in], [1,2]
          assert_equal OrderService::Orders.where(id_eq: 1).query_params[:id_eq], 1
          assert_equal OrderService::Orders.where(placed_at: Date.yesterday..Date.tomorrow).query_params[:placed_at_gteq], Date.yesterday
          assert_equal OrderService::Orders.where(placed_at: Date.yesterday..Date.tomorrow).query_params[:placed_at_lteq], Date.tomorrow
        end

        def test_select
          assert_equal OrderService::Orders.select([:id]).options[:select], [:id]
        end

        def test_includes
          assert_equal OrderService::Orders.includes(:pay_items).options[:includes], [:pay_items]
        end

        def test_order
          assert_equal OrderService::Orders.order(placed_at: :desc).query_params[:s], "placed_at desc"
        end

        def test_paginate
          assert_equal OrderService::Orders.paginate(page: 1, per_page: 10).query_params[:page], 1
          assert_equal OrderService::Orders.paginate(page: 1, per_page: 10).query_params[:per_page], 10
        end
      end
    end
  end
end