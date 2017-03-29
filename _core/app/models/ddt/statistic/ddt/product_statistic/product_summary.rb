#encoding: utf-8
module Ddt
  module ProductStatistic
    class ProductSummary < ::Ddt::ProductStatistic::Base
      include VariantSales
      attr_accessor :sku_in, :category_id_in, :skus, :order_id
      hash_attrs({
        skus: :skus
      })


      def self.class_info
        {
          name: 'product_summary',
          paginate: false,
          permit_params: [:start_time, :category_id_in, :sku_in, :end_time, :branch_id, :time_interval_id],
          default_params: today,
          label: '产品销售统计',
          sortable: false,
          render_view: true, # 渲染自己的html模板
          expose_to_api: true
        }
      end

      def initialize(options={})
        super
        sku_in = options[:sku_in]
        category_ids = options[:category_id_in]
        @order_id = options[:order_id]
        if category_ids.blank?
          @skus = []
        else
          category_ids = category_ids.split(',').map(&:to_i)
          sub_category_ids = Ddt::Category.select(:id).where(parent_id: category_ids).map(&:id)
          all_category_ids = (category_ids + sub_category_ids).uniq
          products_ids = Ddt::Category.find_by_sql("
            SELECT product_id FROM ddt_categories_products WHERE category_id in (#{all_category_ids.join(',')})
            ").map(&:product_id)
          @skus = Ddt::Variant.select(:sku).where(product_id: products_ids).pluck(:sku)
        end
        if sku_in.present?
          @skus = (@skus + sku_in.split(',').map(&:to_i)  ).uniq
        end
      end

      def result
          return [] if branch_id.blank?
          @items ||= merge_variant_sales(variant_sales)
      end

      cache_result do |result|
        @items ||= result
      end

      def filters
        [
          filter_branch(support_all: true),
          filter_start_time,
          filter_end_time,
          filter_time_interval
        ]
      end

      def title
        %W[类别 名称 单点均价 单点数量 单点金额 称重均价 销售重量 称重产品金额 随套餐均价 随套餐数量 随套餐金额 销售均价 销售数量 折前金额 折扣金额 折后金额 销售额占比]
      end

      def body
        items = result
        content = []
        accumulative_rate = 0
        items.each do |h|
          row = []
          row << get_categorie_name(h[:category_names])
          row << h[:name]
          row << h[:avg_price_directly]
          row << h[:sale_directly]
          row << h[:amount_directly]
          row << h[:avg_price_by_weight]
          row << h[:sale_weight]
          row << h[:amount_by_weight]
          row << h[:avg_price_in_combo]
          row << h[:sale_in_combo]
          row << h[:amount_in_combo]
          row << h[:avg_price]
          row << h[:sale_quantity]
          row << h[:original_amount]
          row << h[:adjustment_amount]
          row << h[:amount]
          row << h[:not_actual_amount]
          row << h[:actual_amount]
          row << h[:rate_label]
          content << row
        end
        content
      end

      def foot
        foot_content = []
        moling_amount = 0
        if category_id_in.blank? && sku_in.blank?
          moling_amount = Ddt::OrderService::Api::Statistic.order_moling_amount(
            {
              query:{
                shop_id_eq: shop.id,
                branch_id_eq: (branch_id.to_i == ALL_BRANCH ? nil : branch_id),
                id_eq: order_id,
                pay_item_state_eq: :paid,
                paid_at_gteq: start_time,
                paid_at_lteq: end_time
              }
            }
          )
          foot_content << ['', '抹零', '', '', '', '', '', '', '', '', '','', '','', moling_amount, moling_amount, '', moling_amount, '']
        end

        items = result
        summary_row = []
        summary_row << ''
        summary_row << '合计'
        summary_row << ''
        summary_row << ''
        summary_row << sum(items, :amount_directly)
        summary_row << ''
        summary_row << ''
        summary_row << sum(items, :amount_by_weight)
        summary_row << ''
        summary_row << ''
        summary_row << sum(items, :amount_in_combo)
        summary_row << ''
        summary_row << ''
        summary_row << sum(items, :original_amount)
        summary_row << sum(items, :adjustment_amount) + moling_amount
        summary_row << sum(items, :amount) + moling_amount
        summary_row << sum(items, :not_actual_amount)
        summary_row << sum(items, :actual_amount) + moling_amount
        summary_row << ''
        foot_content << summary_row
        foot_content
      end

      def merge_variant_sales(sales)
        items = sales.flatten
        total = items.map(&:amount).sum.round(2)
        items.group_by(&:sku).map do |sku, items|
          category_names = items[0].category_names
          name = items[0].name
          directly_items = items.select {|i| i.type == :variant}
          by_weight_items= items.select {|i| i.type == :variant_package}
          in_combo_items = items.select {|i| i.type == :combo_product}

          sale_quantity = items.map(&:quantity).sum
          original_amount = items.map(&:amount).sum
          adjustment_amount = items.map(&:adjustment_total).sum
          sum_amount = original_amount + adjustment_amount
          not_actual_amount = items.map(&:not_actual_amount).sum
          actual_amount = sum_amount - not_actual_amount

          sale_directly = directly_items.map(&:quantity).sum
          amount_directly = directly_items.map(&:amount).sum

          sale_by_weight = by_weight_items.map(&:quantity).sum
          sale_weight = by_weight_items.map(&:weight).sum
          amount_by_weight = by_weight_items.map(&:amount).sum

          sale_in_combo = in_combo_items.map(&:quantity).sum
          amount_in_combo = in_combo_items.map(&:amount).sum

          avg_price_directly = ((amount_directly / sale_directly).round(2) rescue 0)
          avg_price_by_weight= ((amount_by_weight / sale_weight).round(2) rescue 0)
          avg_price_in_combo = ((amount_in_combo / sale_in_combo).round(2) rescue 0)

          hash = {
            category_names: category_names,
            name: name,
            avg_price_directly: avg_price_directly,
            sale_directly: sale_directly,
            amount_directly: amount_directly,
            avg_price_by_weight: avg_price_by_weight,
            sale_by_weight: sale_by_weight,
            sale_weight: sale_weight,
            amount_by_weight: amount_by_weight,
            avg_price_in_combo: avg_price_in_combo,
            sale_in_combo: sale_in_combo,
            amount_in_combo: amount_in_combo,
            avg_price: avg(sum_amount,sale_quantity),
            sale_quantity: sale_quantity,
            original_amount: original_amount,
            adjustment_amount: adjustment_amount,
            amount: sum_amount,
            not_actual_amount: not_actual_amount,
            actual_amount: actual_amount,
            rate_label: rate_label(sum_amount, total),
            rate: rate(sum_amount, total)
          }
        end.sort{|a, b| b[:amount] - a[:amount]}
      end

      def get_categorie_name(category_names)
        return '' if category_names.blank?
        category_names = category_names.split(',')
        @categories ||= (branch || shop).categories.with_deleted
        sub_category = @categories.detect{|c| category_names.include?(c.name) && c.parent_id.present?}
        if sub_category.present?
          par_category = @categories.detect{|c| c.id == sub_category.parent_id}
          "#{par_category.name} - #{sub_category.name}"
        else
          category_names[0]
        end
      end

    end
  end
end
