module Ddt
  class Statistic
    module Vip
      class RechargeNotActualAmount < ::Ddt::Statistic::Vip::Base
        def query
          group_by_time_interval(time_column: :created_at, table_name: "ddt_wallet_logs", sql_format: true) do |group_by|
            WalletLog.group(group_by).ransack(query_params).result.sum(:extra_amount)
          end
        end
        alias_method :query_without_cache, :query
        alias_method :query, :query_with_cache
        def query_params
          if branch.present?
            wallet_ids = [branch.card_wallet.id]
          else
            wallet_ids = shop.branches.map(&:card_wallet).map(&:id)
          end
          q.merge({
            shop_id_eq: shop.try(:id),
            wallet_id_in: wallet_ids,
            created_at_gteq: start_date.beginning_of_day,
            created_at_lteq: end_date.end_of_day,
            reason_in: [:for_recharge, :for_recharge_refund_complete]
          })
        end
      end
    end
  end
end