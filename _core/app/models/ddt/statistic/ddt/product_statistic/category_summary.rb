#encoding: utf-8
module Ddt
  module ProductStatistic
    class CategorySummary < Ddt::ProductStatistic::Base
      attr_accessor :skus, :order_id
      include VariantSales

      def initialize(options={})
        super
      end

      def self.class_info
        {
          name: 'category_summary',
          paginate: false,
          permit_params: [:start_time, :end_time, :branch_id],
          default_params: today,
          label: '分类销售统计',
          sortable: true,
          expose_to_api: true
        }
      end

      def filters
        [
          filter_branch(support_all: false),
          filter_start_time,
          filter_end_time,
          filter_time_interval
        ]
      end

      def result
        return [] if branch_id.blank?
        @items ||= merge_variant_sales(variant_sales)
      end
      cache_result

      def title
        ['分类', '售出数量', '售出金额', '占比']
      end

      def body
        items = result
        content = []
        items.each do |item|
          content << item.values
        end
        content
      end

      def foot
        items = result
        [[ '合计', sum(items, :quantity), sum(items, :amount), '']]
      end

      def merge_variant_sales(sales)
        items = sales.flatten
        total = items.map(&:amount).sum.round(2)
        items = split_category_names(items)
        items.group_by(&:category_name).map do |name, items|
          quantity = sum(items, :quantity)
          amount   = sum(items, :amount)
          {
            name: name,
            quantity: quantity,
            amount: amount,
            rate: rate_label(amount, total)
          }
        end
      end

      def split_category_names(items)
        result = []
        items.each do |item|
          if item[:category_names].blank?
            item[:category_name] = '未知'
            result << item
          elsif item[:category_names].include? ','
            # 只计其中的一个分类
            item[:category_name] = item[:category_names].split(',')[-1]
            result << item
          else
            item[:category_name] = item[:category_names]
            result << item
          end
        end
        result
      end

    end
  end
end
