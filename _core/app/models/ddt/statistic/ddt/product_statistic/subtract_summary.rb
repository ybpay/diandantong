module Ddt
  module ProductStatistic
    class SubtractSummary < Ddt::ProductStatistic::Base

      def self.class_info
        {
          name: 'subtract_summary',
          paginate: false,
          permit_params: [:start_time, :end_time, :branch_id],
          default_params: today,
          label: '退菜统计',
          sortable: true,
          expose_to_api: true
        }
      end

      def result
        return [] if branch_id.blank?
        params = {
          query: {
            shop_id_eq: shop.id,
            branch_id_eq: branch_id
            }
        }
        query = params[:query]

        @items = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:order_number, :order_id, :table_name, :table_zone_name, 
                            :placed_at, :created_at, :itemable_type, :itemable_id, :itemable_name, 
                            :product_name, :price, :subtract_reason, :operator_id, 
                            :operator_type, :operator_name, :settle_account_id, :source_line_tiem_id],
            accumulate_keys: [:quantity]
        ) do |current_date, next_date, has_next|
          query[:created_at_gteq] = current_date
          if (has_next)
            query[:created_at_lt] = next_date
          else
            query.delete(:created_at_lt)
            query[:created_at_lteq] = next_date
          end
          Ddt::OrderService::Api::Statistic.subtract_item_list(params)
        end
      end
      cache_result

      def filters
        [
          filter_branch(support_all: false),
          filter_start_time,
          filter_end_time
        ]
      end

      def title
        %W[产品编号（sku） 名称 单位 点单数量 退菜数量 退菜率 单价 退菜金额 退菜原因]
      end

      def body
        return [] if branch_id.blank?
        items = result
        items = group_by_itemable_id(items)
        content = []
        items.each do |item|
          content << [
            sku(item[:itemable_type], item[:itemable_id]),
            item[:itemable_name],
            unit_name(item[:itemable_type], item[:itemable_id]),
            item[:order_num],
            item[:subtract_num],
            item[:rate],
            item[:price],
            item[:amount],
            item[:reasons]
          ]
        end
        content
      end

      def foot
        items = result
        items = group_by_itemable_id(items)
        [['总计','-','-','-',sum(items, :subtract_num), '-', '-', sum(items, :amount), '-']]
      end

      def group_by_itemable_id(items)
        list = items
        order_ids = list.map {|l| l[:order_id]}.uniq
        order_nums = Ddt::OrderService::Api::Statistic.line_item_quantity(
          query: {
            shop_id_eq: shop.id,
            branch_id_eq: branch_id,
            order_id_in: order_ids,
            is_subtract_eq: false
          },
          group_by: [:itemable_id]
        )
        hash = group(list, :itemable_id)
        hash.map do |k,v|
          first = v[0]
          sum_quantity = sum(v, :quantity)
          sum_amount   = sum_quantity * first[:price]
          reasons = count_join(v, :subtract_reason)
          order_num = order_nums[k] rescue 1
          sums = {
            order_num: order_num.to_i,
            subtract_num: sum_quantity,
            rate:  ((sum_quantity * 1.0) / order_num).round(4),
            amount: sum_amount,
            reasons: reasons
          }
          first.merge(sums)
        end
      end



    end
  end
end
