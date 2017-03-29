module Ddt
  module UserStatistic
    class ConsumeSummary < ::Ddt::UserStatistic::Base

      def self.class_info
        {
          name: 'consume_summary',
          paginate: false,
          permit_params: [:start_time, :end_time],
          label: '消费汇总',
          sortable: true
        }
      end

      def result
        # @items = shop.wallet_logs.joins(:wallet)
        #     .select('ddt_wallet_logs.shop_id, branch_id, count(*) as count_all, -sum(ddt_wallet_logs.amount) as amount, -sum(ddt_wallet_logs.cash_amount) as cash_amount, -sum(ddt_wallet_logs.extra_amount) as extra_amount')
        #     .where(ddt_wallets: {type: 'Ddt::UserCardWallet'}, reason: [:for_exchange, :for_deduction, :for_deduction_cancel, :for_vip_card_pay, :for_rollback_vip_card_pay], ddt_wallet_logs: {created_at: start_time..end_time})
        #     .group(:branch_id)
        @items = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:branch_id],
            accumulate_keys: [:count_all, :amount, :cash_amount, :extra_amount]
        ) do |current_date, next_date, has_next|
          if (has_next)
            params = {st_time: current_date...next_date}
          else
            params = {st_time: current_date..next_date}
          end
          shop.wallet_logs.joins(:wallet)
          .select('ddt_wallet_logs.shop_id, branch_id, count(*) as count_all, -sum(ddt_wallet_logs.amount) as amount, -sum(ddt_wallet_logs.cash_amount) as cash_amount, -sum(ddt_wallet_logs.extra_amount) as extra_amount')
          .where(ddt_wallets: {type: 'Ddt::UserCardWallet'}, reason: [:for_exchange, :for_deduction, :for_deduction_cancel, :for_vip_card_pay, :for_rollback_vip_card_pay], ddt_wallet_logs: params)
          .group(:branch_id).map{|line_item|
            {
              branch_id:        line_item.branch_id,
              count_all:        line_item.count_all,
              amount:           line_item.amount,
              cash_amount:      line_item.cash_amount,
              extra_amount:     line_item.extra_amount
            }
          }
        end
      end
      cache_result

      def filters
        [
          filter_start_time,
          filter_end_time
        ]
      end

      def title
        %W(门店 消费次数 消费金额 主账户消费 附属账户消费)
      end

      def body
        items = result
        content = []
        items.each do |item|
          content << [
            get_branch_name(item[:branch_id]),
            item[:count_all],
            item[:amount],
            item[:cash_amount],
            item[:extra_amount]
          ]
        end
        content
      end

      def foot
        items = result
        [["总计", sum(items, :count_all), sum(items, :amount), sum(items, :cash_amount), sum(items, :extra_amount) ]]
      end

    end
  end
end
