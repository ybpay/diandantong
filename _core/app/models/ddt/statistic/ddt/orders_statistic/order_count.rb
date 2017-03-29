#encoding: utf-8
module Ddt
  module OrdersStatistic
    class OrderCount < OrdersStatistic::Base

      def group_by_column
        :paid_at_month
      end

      def title
        %W[时段 消费总额 折扣金额 销售金额 订单数 客人数 单均 人均]
      end

      def body
        items = result
        content = []
        keys.each do |key|
          content << items[key].values
        end if items.present?
        content
      end

      def foot
        return @foot if @foot.present?
        body_data = body
        if body_data.present?
          first = body_data.shift
          zip_data = first.zip(*body_data)
          zip_data.shift
          zip_data = zip_data.map(&:sum)
          zip_data[5] = avg(zip_data[2], zip_data[3])
          zip_data[6] = avg(zip_data[2], zip_data[4])
          zip_data.unshift('总计')
          @foot = [zip_data]
        else
          @foot = [[]]
        end
      end

      def result
        return @hash if @hash.present?
        items = query
        @hash = {}
        keys.each_with_index do |key, index|
          label = labels[index]
          @hash[key] = {
            time: label,
            consume_total: 0,
            adjustment_total: 0,
            amount: 0,
            count: 0,
            guest_num: 0,
            per_order_consume: 0,
            per_guest_consume: 0
          }
          items.each do |item|
            if item[group_alias] == key
              @hash[key] = {
                time: label,
                consume_total: (item[:adjustment_total].abs + item[:total]),
                adjustment_total: item[:adjustment_total],
                amount: item[:total],
                count: item[:times],
                guest_num: item[:guest_num] || 0,
                per_order_consume: avg(item[:total], item[:times]),
                per_guest_consume: avg(item[:total], item[:guest_num])
              }
            end
          end
        end
        @hash
      end
      cache_result

      def query
        # return [] if branch_id.blank?
        # query_params = {
        #     shop_id_eq: shop.id,
        #     paid_at_gteq: start_time,
        #     paid_at_lteq: end_time,
        #     type_in: Ddt::OrderService::Order::Base.base_types
        #     }
        # query_params[:branch_id_eq] = branch_id if one_branch?
        # @items ||= Ddt::OrderService::Api::Statistic.order_times_total(
        #   query: query_params,
        #   group_by: group_by_column,
        #   where: time_interval_clause
        # )

        return [] if branch_id.blank?
        params = {
            query: {
                shop_id_eq: shop.id,
                type_in: Ddt::OrderService::Order::Base.base_types
            },
            group_by: group_by_column,
            where: time_interval_clause
        }
        params[:query][:branch_id_eq] = branch_id if one_branch?

        query = params[:query]

        @items = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:time],
            accumulate_keys: [:adjustment_total, :total, :guest_num, :times]
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
              times:                  line_item.times,
              total:                  line_item.total,
              adjustment_total:       line_item.adjustment_total,
              guest_num:              line_item.guest_num,
              time:                   line_item.time
            }
          }
        end
      end

    end
  end
end
