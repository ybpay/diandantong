# encoding: utf-8
module Ddt
  module ProductStatistic
    class VariantSummary < ::Ddt::ProductStatistic::Base
      # group_by       : sku or itemable_id
      # filters        : skus or variant_ids
      # pay_item_state : paid || unpaid || all
      attr_accessor :group_by, :filters, :pay_item_state, :order_id
      hash_attrs({
         分组方式: :group_by,
         过滤: :filters,
         支付状态: :pay_item_state
      })

      def initialize(options={})
        super
        @group_by = options[:group_by] || :sku
        @filters  = options[:filters] || []
        @pay_item_state = options[:pay_item_state] || :paid
        @order_id = options[:order_id]
      end

      def result
        query = { shop_id_eq: shop.id, pay_item_state_eq: pay_item_state}
        query[:branch_id_eq] = branch_id if one_branch?
        query[:order_id_eq] = order_id if order_id.present?
        if @filters.present? && [:itemable_id, :sku].include?(group_by)
          query["#{group_by}_in".to_sym] = @filters
        end

        # 按时间分析
        params = {where: time_interval_clause, query: query, group: group_by}
        split_query_name = pay_item_state.to_sym == :paid ? 'paid_at' : 'placed_at'

        @items ||= split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:category_names, :itemable_name, :price, :sku, :itemable_id],
            accumulate_keys: [:quantity, :amount, :adjustment_amount, :adjustment_total, :not_actual_amount]
        ) do |current_date, next_date, has_next|
          query[(split_query_name + '_gteq').to_sym] = current_date
          if has_next
            query[(split_query_name + '_lt').to_sym] = next_date
          else
            query.delete((split_query_name + '_lt').to_sym)
            query[(split_query_name + '_lteq').to_sym] = next_date
          end
          Ddt::OrderService::Api::Mock::Statistic.variant_sale_summary(params)
        end
      end

      def to_variant_sales
        @items ||= result
        @items.map do |item|
          {
            type: :variant,
            sku: item[:sku],
            itemable_id: item[:itemable_id],
            category_names: item[:category_names],
            name:  item[:itemable_name],
            quantity: item[:quantity],
            adjustment_total: item[:adjustment_total],
            not_actual_amount: item[:not_actual_amount],
            amount:   item[:amount].round(2)
          }.to_obj
        end
      end

    end
  end
end
