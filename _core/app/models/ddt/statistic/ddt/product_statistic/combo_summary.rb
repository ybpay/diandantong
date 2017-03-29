module Ddt
  module ProductStatistic
    class ComboSummary < ::Ddt::ProductStatistic::Base

      def self.class_info
        {
          name: 'combo_summary',
          paginate: false,
          permit_params: [:start_time, :end_time, :branch_id],
          default_params: today,
          label: '套餐统计',
          sortable: true,
          expose_to_api: true
        }
      end

      def result
        return [] if branch_id.blank?

        params = {
            where: time_interval_clause,
            query: {
                shop_id_eq: shop.id,
                branch_id_eq: branch_id,
                shop_pay_item_state_eq: 'paid'
            }
        }
        query = params[:query]

        items = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:product_name, :itemable_id, :itemable_name, :original_price, :price],
            accumulate_keys: [:quantity, :adjustment_total, :not_actual_amount]
        ) do |current_date, next_date, has_next|
          # Rails.logger.info("[Statistics][ComboSummary] shop=#{shop.id}, branch=#{branch.id}, current_date=#{current_date}, next_date=#{next_date}, has_next=#{has_next}")
          query[:created_at_gteq] = current_date
          if (has_next)
            query[:created_at_lt] = next_date
          else
            query.delete(:created_at_lt)
            query[:created_at_lteq] = next_date
          end
          Ddt::OrderService::Api::Statistic.combo_item_list(params)
        end
        group_by_combo(items)
      end
      cache_result

      def filters
        [
          filter_branch(support_all: false),
          filter_start_time,
          filter_end_time,
          filter_time_interval
        ]
      end

      def title
        %W[套餐名 销售数量 原价金额 折扣 非实收 销售金额 占套餐比例]
      end

      def body
        items = result
        return [] if items.blank?
        content = []
        items.each do |item|
          content << item.values
        end
        content
      end

      def foot
        items = result
        [['总计', sum(items, :quantity),sum(items, :original_amount), sum(items, :adjustment_total), sum(items, :not_actual_amount), sum(items, :amount),'']]
      end

      def group_by_combo(items)
        cal_amount = ->(item){ item[:quantity] * (item[:price]) }
        cal_original_amount = ->(item){ item[:quantity] * (item[:original_price] || item[:price]) }
        total = sum(items, &cal_amount)
        hash = group(items, :product_name)
        hash.map do |combo_name, line_items|
          amount = sum(line_items, &cal_amount)
          original_amount = sum(line_items, &cal_original_amount)
          {
            combo_name: combo_name,
            quantity: sum(line_items, &Proc.new{|item| item[:quantity]}),
            original_amount: original_amount,
            adjustment_total: sum(line_items, &Proc.new{|item| item[:adjustment_total]}),
            not_actual_amount: sum(line_items, &Proc.new{|item| item[:not_actual_amount]}),
            amount:   amount,
            rate: rate_label(amount,total)
          }
        end.sort{|a, b| b[:amount]-a[:amount]}
      end

    end
  end
end
