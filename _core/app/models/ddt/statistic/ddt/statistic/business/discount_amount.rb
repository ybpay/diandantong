module Ddt
  class Statistic
    module Business
      class DiscountAmount < ::Ddt::Statistic::Business::Base
        def query
          group_by_time_interval do |group_by|
            OrderService::Api::Statistic.adjustment_amount(query: query_params, group_by: group_by)
          end
        end
        alias_method :query_without_cache, :query
        alias_method :query, :query_with_cache
        def query_params
          q.merge({
            shop_id_eq: shop.try(:id),
            branch_id_eq: branch.try(:id),
            created_at_gteq: start_date.beginning_of_day,
            created_at_lteq: end_date.end_of_day,
            reason_in: OrderService::Adjustment.discount_reasons
          })
        end
      end
    end
  end
end