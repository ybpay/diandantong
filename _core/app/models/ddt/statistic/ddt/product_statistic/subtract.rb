#encoding: utf-8
module Ddt
  module ProductStatistic
    class Subtract < ::Ddt::ProductStatistic::Base
      attr_accessor :order_number, :subtract_reason, :records, :operator_id
      hash_attrs({
          订单号: :order_number,
          退菜原因: :subtract_reason,
          操作员: :operator_id
      })

      def self.class_info
        {
          name: 'subtract',
          paginate: false,
          permit_params: [:start_time, :end_time, :branch_id, :order_number, :subtract_reason, :operator_id],
          paginate: true,
          label: '退菜记录'
        }
      end

      def initialize(options={})
        super
        @order_number = options[:order_number]
        @subtract_reason = options[:subtract_reason]
        @operator_id = options[:operator_id]
      end

      def to_params
        {
          branch_id: branch_id,
          start_time: start_time,
          end_time: end_time
        }
      end

      def filters
        [
          filter_branch(support_all: false),
          {name: 'order_number', type: 'string', placeholder: '订单号'},
          {name: 'subtract_reason', type: 'collection', collection: shop.subtract_reasons.map(&:name), prompt: '退菜原因', include_blank: true},
          {name: 'operator_id', type: 'ddselect2', data: {useas: "local_select", "local-datas" => shop.accounts.with_deleted.map{|a| {id: a.id, name: a.name}}, single: true, placeholder: "选择退菜人"}},
          filter_start_time,
          filter_end_time
        ]
      end

      def result
        return [] if branch_id.blank?
        params = {
          query: {
            shop_id_eq: shop.id,
            branch_id_eq: branch_id,
            order_number_eq: order_number,
            subtract_reason_eq: subtract_reason,
            order_change_log_operator_id_eq: operator_id
            },
          page: (page || 1)
        }
        query = params[:query]

        @records = split_query_by_time(
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
        @records = wrap_paginate(@records)
      end

      cache_result

      def title
        %W[单号 桌台 产品编号（sku） 名称 单位 单价 退菜数量 退菜金额 退菜人 退菜原因 点菜时间 退菜时间]
      end

      def body
        items = result
        content = []
        items.each do |item|
          content << [
            item[:order_number],
            item[:table_zone_name],
            sku(item[:itemable_type], item[:itemable_id]),
            item[:itemable_name],
            unit_name(item[:itemable_type], item[:itemable_id]),
            item[:price],
            item[:quantity],
            (item[:price] * item[:quantity]).round(2),
            item[:operator_name].gsub('工作人员: ', ''),
            item[:subtract_reason],
            item[:placed_at],
            item[:created_at]
          ]
        end
        content
      end

      def link_template
        {
          0 => order_link_template
        }
      end

      def link_hash
        items = result
        order_number_id_hash(items)
      end

    end
  end
end
