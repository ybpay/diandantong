module Ddt
  class Statistic
    module Vip
      class PayActualAmount < ::Ddt::Statistic::Vip::Base
        def query
          group_by_time_interval(time_column: :created_at, table_name: "ddt_wallet_logs", sql_format: true) do |group_by|
            WalletLog.group(group_by).ransack(query_params).result.sum(:cash_amount)
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
            amount_gt: 0,
            reason_eq: "for_vip_card_pay"
          })
        end
      end
    end
  end
end