module Ddt
  module UserStatistic
    class CreditsSummary < ::Ddt::UserStatistic::Base

      def self.class_info
        {
          name: 'credits_summary',
          permit_params: [:start_time, :end_time],
          sortable: true,
          label: '积分合计'
        }
      end

      def filters
        [
          filter_start_time,
          filter_end_time
        ]
      end

      def result
        # @items = shop.wallet_logs.joins(:wallet)
        #              .select('branch_id, reason, sum(ddt_wallet_logs.amount) as amount')
        #              .where(ddt_wallets: {type: 'Ddt::UserCreditsWallet'}, reason: [:for_deduction, :for_deduction_cancel, :for_exchange, :for_grant], ddt_wallet_logs: {created_at: start_time..end_time})
        #              .group(:branch_id, :reason)
        # merge(@items)

        @items = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:branch_id, :reason],
            accumulate_keys: [:amount]
        ) do |current_date, next_date, has_next|
          if (has_next)
            params = {st_time: current_date...next_date}
          else
            params = {st_time: current_date..next_date}
          end
          shop.wallet_logs.joins(:wallet)
          .select('branch_id, reason, sum(ddt_wallet_logs.amount) as amount')
          .where(ddt_wallets: {type: 'Ddt::UserCreditsWallet'}, reason: [:for_deduction, :for_deduction_cancel, :for_exchange, :for_grant], ddt_wallet_logs: params)
          .group(:branch_id, :reason).map{|line_item|
            {
              branch_id:        line_item.branch_id,
              reason:           line_item.reason,
              amount:           line_item.amount
            }
          }
        end
        merge(@items)
      end

      cache_result

      def title
        %W[门店 送出积分 已消费 差额]
      end

      def body
        content = []
        result.each_pair do |branch_id, v|
          row = []
          row << get_branch_name(branch_id, blank_label: '平台', noexist_label: '未知来源')
          row << v[:for_grant]
          row << v[:for_consume]
          row << (branch_id.nil? ? '' : v[:for_consume] - v[:for_grant])
          content << row
        end
        content
      end

      def foot
        content = ['合计']
        content << result.map{|k,v| v[:for_grant]}.sum
        content << result.map{|k,v| v[:for_consume]}.sum
        content << ''
        [content]
      end

      def merge(items)
        h = {}
        items.each do |item|
          h[item[:branch_id]] ||= {for_consume: 0, for_grant: 0}
          reason =\
          case item[:reason].to_sym
          when :for_deduction, :for_deduction_cancel, :for_exchange
            :for_consume
          when :for_grant
            :for_grant
          end

          amount =\
          case item[:reason].to_sym
          when :for_deduction_cancel
            - item[:amount]
          else
            item[:amount].abs
          end
          h[item[:branch_id]][reason] += amount
        end
        h
      end

    end
  end
end
