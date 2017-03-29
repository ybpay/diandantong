#encoding: utf-8
module Ddt
  module ProductStatistic
    class ProductContrast < ::Ddt::ProductStatistic::Base
      attr_accessor :skus
      hash_attrs({
          skus: :skus
      })

      def self.class_info
        {
          name: 'product_contrast',
          paginate: false,
          permit_params: [:start_time, :sku_in, :end_time],
          default_params: today,
          label: '菜品销售对比表',
          sortable: true,
          render_view: true, # 渲染自己的html模板
          expose_to_api: true
        }
      end

      def initialize(options={})
        super
        sku_in = options[:sku_in]
        @skus = sku_in.split(',').uniq if sku_in.present?
      end

      def result
        query = {
            skus: skus,
            shop_id: shop.id
        }
        @items ||= split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:sku, :branch_id, :itemable_type, :product_name, :itemable_name, :category_names],
            accumulate_keys: [:quantity, :amount, :adjustment_total, :not_actual_amount]
        ) do |current_date, next_date, has_next|
          # Rails.logger.info("[Statistics][ProductContrast] shop=#{shop.id}, branch=#{branch.id}, current_date=#{current_date}, next_date=#{next_date}, has_next=#{has_next}")
          query[:start_time_gteq] = current_date
          if (has_next)
            query[:end_time_lt] = next_date
          else
            query.delete(:end_time_lt)
            query[:end_time_lteq] = next_date
          end
          Ddt::OrderService::Api::Statistic.line_item_list(query)
        end
        @items.group_by{|l| l[:sku]}
      end

      cache_result do |result|
        @items ||= result
      end

      def title
        %W[SKU 类别 名称 合计金额 合计数量] +
        shop.branches.map{|b| ["#{b.name}实收金额", "#{b.name}结算数量"]}.flatten
      end

      def body
        return @body if @body.present?
        @body = []
        result.each do |sku, items|
          first_item = items.first
          row = []
          row << sku
          row << first_item[:category_names]
          row << (first_item[:itemable_type] == "Ddt::Variant" ? first_item[:itemable_name] : first_item[:product_name])
          row << items.map{|item| item[:amount]}.sum.round(2)
          row << items.map{|item| item[:quantity]}.sum
          shop.branches.each do |branch|
            item = items.detect{|item| item[:branch_id] == branch.id }
            if item.present?
              row << (item[:amount] - item[:not_actual_amount]).round(2)
              row << item[:quantity]
            else
              row << 0
              row << 0
            end
          end
          @body << row
        end
        @body
      end

      def foot
        []
      end
    end
  end
end
