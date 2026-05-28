module Ddt
  class Statistic
    module Order
      class Quantity < ::Ddt::Statistic::Order::Base
        def query
          group_by_time_interval do |group_by|
            OrderService::Api::Statistic.order_quantity(query: order_query_params, group_by: group_by)
          end
        end
        alias_method :query_without_cache, :query
        alias_method :query, :query_with_cache
        private
        def order_query_params
          base_order_query_params.merge(paid_at_gteq: start_date.beginning_of_day, paid_at_lteq: end_date.end_of_day)
        end
      end
    end
  end
end
