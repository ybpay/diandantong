#encoding: utf-8
module Ddt
  module ProductStatistic
    class VariantPackageSummary < ::Ddt::ProductStatistic::Base
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
        group_items(time_interval: @time_interval)
      end

      cache_result

      def search_items(options={})
        query = { shop_id_eq: shop.id, pay_item_state_eq: pay_item_state}
        query[:order_id_eq] = order_id if order_id.present?
        query[:branch_id_eq] = branch_id if one_branch?
        if @filters.present? && [:itemable_id, :sku].include?(group_by)
          query["#{group_by}_in".to_sym] = @filters
        end

        if @items.present?
          @items
        else
          # 按时间分析
          where = @time_interval.present? ? "CAST(paid_at AS TIME) between '#{@time_interval.start.strftime('%T')}' and '#{@time_interval.end.strftime('%T')}'" : 1
          params = {where: where, query: query}
          split_query_name = pay_item_state.to_sym == :paid ? 'paid_at' : 'placed_at'

          @items ||= split_query_by_time(
              start_time: start_time,
              end_time: end_time,
              identity_keys: [:product_name, :itemable_name, :itemable_id, :unit_name, :category_names, :sku, :price],
              accumulate_keys: [:quantity, :amount, :adjustment_total, :not_actual_amount]
          ) do |current_date, next_date, has_next|
            query[(split_query_name + '_gteq').to_sym] = current_date
            if has_next
              query[(split_query_name + '_lt').to_sym] = next_date
            else
              query.delete((split_query_name + '_lt').to_sym)
              query[(split_query_name + '_lteq').to_sym] = next_date
            end
            OrderService::Api::Statistic.by_weight_product_sale_list(params)
          end

          @items.each do |item|
            item[:weight] = item[:itemable_name] =~ /(重量: ([\d\.]+)#{item[:unit_name]})/ ? Float($2) : 0
          end
        end
      end

      def group_items(options = {})
          # [
          #   {
          #     category_names: ''
          #     name: "青鱼"
          #     unit_name: '斤'
          #     variants: [{
          #       category_names:''
          #       name: "青鱼(大)",
          #       weight: ,
          #       quantity:
          #       amount:
          #     }],
          #     total_weight:,
          #     total_quantity:
          #     total_amount:
          #   }
          # ]
          @group_items ||= search_items(options).group_by{|item| item[:product_name]}.map do |product_name, pitems|
            variants = pitems.group_by{|item| item[:sku]}.map do |sku, vitems|
              variant_name = vitems[0][:itemable_name]
              category_names = vitems[0][:category_names]
              {
                sku: sku,
                name: variant_name,
                category_names: category_names,
                weight: vitems.map{|vitem| vitem[:weight] * vitem[:quantity]}.sum.round(2),
                quantity: vitems.map{|vitem| vitem[:quantity]}.sum,
                amount: vitems.map{|vitem| vitem[:amount]}.sum.round(2),
                adjustment_total: vitems.map{|vitem| vitem[:adjustment_total]}.sum.round(2),
                not_actual_amount: vitems.map{|vitem| vitem[:not_actual_amount]}.sum.round(2)
              }
            end
            total_amount = variants.map{|v| v[:amount]}.sum.round(2)
            variants.each do |v|
              v[:percent] = (v[:amount] / total_amount).round(4)
            end
            {
              name: product_name,
              unit_name: pitems.first[:unit_name],
              variants: variants,
              total_weight:   variants.map{|v| v[:weight]}.sum.round(2),
              total_quantity: variants.map{|v| v[:quantity]}.sum,
              total_amount:   variants.map{|v| v[:amount]}.sum,
            }
          end
        end


      def to_csv(file = StringIO.new)
        csv = CSV.new(file)
        items = result
        csv << %W[产品 规格 数量 重量 单位 金额 金额占比]
        items.each do |product|
          product[:variants].each do |variant|
            csv_line = []
            csv_line << product[:name]
            csv_line << variant[:name]
            csv_line << variant[:weight]
            csv_line << variant[:unit_name]
            csv_line << variant[:amount]
            csv_line << variant[:percent]
            csv_line
            csv << csv_line
          end
          csv << ['', '',
            product[:total_quantity],
            product[:total_weight], '',
            product[:total_amount], ''
          ]
        end
      end

      def to_variant_sales
        items = result
        items.map{|p| p[:variants]}.flatten.map(&:to_obj).group_by(&:sku).map do |sku, vitems|
          variant_name = vitems[0].name
          {
            sku: sku,
            type: :variant_package,
            name: variant_name,
            category_names: vitems.first.category_names,
            quantity: vitems.map(&:quantity).sum,
            weight: vitems.map(&:weight).sum.round(2),
            amount: vitems.map(&:amount).sum.round(2),
            adjustment_total: vitems.map(&:adjustment_total).sum.round(2),
            not_actual_amount: vitems.map(&:not_actual_amount).sum.round(2)
          }.to_obj
        end
      end

    end
  end
end
