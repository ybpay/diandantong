module Ddt
  class Statistic
    module Vip
      class NewCount < ::Ddt::Statistic::Vip::Base
        def query
          group_by_time_interval(time_column: :become_vip_at, table_name: "ddt_vip_infos", sql_format: true) do |group_by|
            Ddt::VipInfo.group(group_by).ransack(query_params).result.count
          end
        end
        alias_method :query_without_cache, :query
        alias_method :query, :query_with_cache
        def query_params
          q.merge({
            shop_id_eq: shop.try(:id),
            from_branch_id_eq: branch.try(:id),
            become_vip_at_gteq: start_date.beginning_of_day,
            become_vip_at_lteq: end_date.end_of_day
          })
        end
      end
    end
  end
end