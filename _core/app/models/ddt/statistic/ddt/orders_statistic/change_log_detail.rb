#encoding: utf-8
module Ddt
  module OrdersStatistic
    class ChangeLogDetail < OrdersStatistic::Base
      attr_accessor :type, :records
      hash_attrs({
          订单日志类型: :type
      })

      def initialize(options={})
        super
        @type = options[:type]
        @type = 'Ddt::OrderChangeLog.OrderCancel' if @type.blank?
      end

      def self.class_info
        {
          name: 'change_log_detail',
          permit_params: [:branch_id, :type],
          label: '退单与反结帐明细',
          sortable: true
        }
      end

      def type_collection
        [
          ['订单取消记录', "Ddt::OrderChangeLog::OrderCancel"],
          ['订单反结纪录', "Ddt::OrderChangeLog::AntiSettlement"],
          ['订单退菜纪录', "Ddt::OrderChangeLog::DeleteItemable"]
        ]
      end

      def type_name(type)
        Ddt::OrderService::OrderChangeLog.type_collection_hash.detect{|item| type == item[:value].to_s}[:name]
      end

      def order_type_name(type)
        Ddt::OrderService::Order::Base.type_collection_hash.detect{|item| type == item[:value].to_s}[:name]
      end

      def result
        return [] if branch_id.blank?

        query = {
            shop_id_eq: shop.id,
            branch_id_eq: branch_id,
            type_eq: type
        }

        @records ||= split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            concat: true
        ) do |current_date, next_date, has_next|
          if (has_next)
            q = query.merge(created_at_gteq: current_date, created_at_lt: next_date)
          else
            q = query.merge(created_at_gteq: current_date, created_at_lteq: next_date)
          end
          Ddt::OrderService::Api::Statistic.order_change_list({query: q})
        end
      end
      
      cache_result

      def title
        ["类型","订单编号", "订单类型", "桌台", "备注", "操作者", "时间"]
      end

      def body
        items = result
        content = []
        items.each do |item|
          content << [
            type_name(item[:type]),
            item[:order_number],
            item[:order_type].present? ? order_type_name(item[:order_type]) : nil,
            item[:order_table_zone_name],
            item[:description],
            item[:operator_name],
            item[:created_at].strftime('%F %T')
          ]
        end
        content
      end

      def filters
        [
          filter_branch(support_all: false),
          {name: 'type', type: 'collection', collection: type_collection, prompt: '类型', include_blank: false},
          filter_start_time,
          filter_end_time
        ]
      end

      def link_template
        {
          1 => order_link_template
        }
      end

      def link_hash
        items = result
        order_number_id_hash(items)
      end

    end
  end
end
