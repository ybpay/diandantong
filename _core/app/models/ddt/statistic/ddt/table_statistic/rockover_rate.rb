module Ddt
  module TableStatistic
    class RockoverRate < TableStatistic::Base
      attr_accessor :tables, :branch_id

      def result
        # query_params = {
        #   shop_id_eq: shop.id,
        #   paid_at_gteq: start_time,
        #   paid_at_lteq: end_time
        # }
        # @items ||= Ddt::OrderService::Api::Statistic.order_times_total(
        #   query: query_params,
        #   group_by: :branch_id
        # )
        # @items
###################################################################################
        params = {
            query: {
                shop_id_eq: shop.id
            },
            group_by: :branch_id
        }
        query = params[:query]

        @items ||= split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:branch_id],
            accumulate_keys: [:times, :adjustment_total, :total, :guest_num]
        ) do |current_date, next_date, has_next|
          query[:paid_at_gteq] = current_date
          if (has_next)
            query[:paid_at_lt] = next_date
          else
            query.delete(:paid_at_lt)
            query[:paid_at_lteq] = next_date
          end
          Ddt::OrderService::Api::Statistic.order_times_total(params).map{|line_item|
            {
              times:                   line_item.times,
              adjustment_total:        line_item.adjustment_total,
              total:                   line_item.total,
              guest_num:               line_item.guest_num,
              branch_id:               line_item.branch_id
            }
          }
        end
      end
      cache_result

      def rockover_rate(order_times, table_count)
        r = rate(order_times-table_count, table_count)
        "#{r<0 ? 0:r}%"
      end

      def get_branch_tables(branch_id)
        @tables ||= Ddt::Table.includes(:table_zone).where(shop_id: shop.id)
        @tables.select{|table| table.branch_id == branch_id}
      end

      def meal_num
        # 一天两餐
        2
      end
    end
  end
end
