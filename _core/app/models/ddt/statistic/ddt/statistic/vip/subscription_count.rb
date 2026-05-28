module Ddt
  class Statistic
    module Vip
      class SubscriptionCount < ::Ddt::Statistic::Vip::Base
        def query
          group_by_time_interval(time_column: :created_at, table_name: "ddt_base_users", sql_format: true) do |group_by|
            Ddt::User.group(group_by).ransack(query_params).result.count
          end
        end
        alias_method :query_without_cache, :query
        alias_method :query, :query_with_cache
        def query_params
          q.merge({
            shop_id_eq: shop.try(:id),
            from_branch_id_eq: branch.try(:id),
            created_at_gteq: start_date.beginning_of_day,
            created_at_lteq: end_date.end_of_day
          })
        end
      end
    end
  end
end