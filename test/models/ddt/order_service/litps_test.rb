require "test_helper"
module Ddt
  module OrderService
    class LitpsTest < TestCase::Base
      concerning :Query do
        def test_scope
          assert_equal OrderService::Litps.by_state(:pending).query_params[:state_eq], :pending
          assert_equal OrderService::Litps.by_state(nil).query_params[:state_eq], nil
          assert OrderService::Litps.by_created_at(1.day.ago, Time.now).query_params.has_key?(:created_at_gt)
          assert OrderService::Litps.by_created_at(1.day.ago, Time.now).query_params.has_key?(:created_at_lt)
          assert !OrderService::Litps.by_created_at(nil, nil).query_params.has_key?(:created_at_gt)
        end

        def test_where
          assert_equal OrderService::Litps.where(id: 1).query_params[:id_eq], 1
          assert_equal OrderService::Litps.where(id: [1,2]).query_params[:id_in], [1,2]
          assert_equal OrderService::Litps.where(id_eq: 1).query_params[:id_eq], 1
          assert_equal OrderService::Litps.where(created_at: Date.yesterday..Date.tomorrow).query_params[:created_at_gteq], Date.yesterday
          assert_equal OrderService::Litps.where(created_at: Date.yesterday..Date.tomorrow).query_params[:created_at_lteq], Date.tomorrow
        end

        def test_order
          assert_equal OrderService::Litps.order(created_at: :desc).query_params[:s], "created_at desc"
        end

        def test_paginate
          assert_equal OrderService::Litps.paginate(page: 1, per_page: 10).query_params[:page], 1
          assert_equal OrderService::Litps.paginate(page: 1, per_page: 10).query_params[:per_page], 10
        end
      end
    end
  end
end