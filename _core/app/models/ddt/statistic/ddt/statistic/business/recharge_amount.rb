module Ddt
  class Statistic
    module Business
      class RechargeAmount < ::Ddt::Statistic::Business::Base
        def query
          group_by_time_interval do |group_by|
            OrderService::Api::Statistic.pay_item_actual_amount(query: query_params, group_by: group_by)
          end
        end
        alias_method_chain :query, :cache

        def query_params
          q.merge({
            shop_id_eq: shop.try(:id),
            branch_id_eq: branch.try(:id),
            created_at_gteq: start_date.beginning_of_day,
            created_at_lteq: end_date.end_of_day,
            order_type_eq: "Ddt::RechargeOrder"
          })
        end
      end
    end
  end
end