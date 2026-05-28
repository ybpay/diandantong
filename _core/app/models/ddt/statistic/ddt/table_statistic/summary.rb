module Ddt
  module TableStatistic
    class Summary < TableStatistic::Base
      attr_accessor :tables

      def self.class_info
        {
          name: 'summary',
          paginate: false,
          permit_params: [:branch_id, :start_time, :end_time],
          label: '台号用量',
          sortable: true
        }
      end

      def tables
        @tables ||= Ddt::Table.with_discarded.includes(:table_zone).where(branch_id: branch_id)
      end

      def result
        return [] if branch_id.blank?
        @items ||= Ddt::OrderService::Api::Statistic.order_times_total({
          query: {
            shop_id_eq: shop.id,
            branch_id_eq: branch_id,
            paid_at_gteq: start_time,
            paid_at_lteq: end_time,
            type_eq: 'Ddt::EatInHallOrder',
            table_id_in: tables.map(&:id)
          },
          group_by: :table_id
        })
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
        %w[桌台类型 桌台名称 订单数 消费人数 订单总价 单均消费 人均消费]
      end

      def body
        return [] if branch_id.blank?
        content = []
        tables.each do |table|
          order = result.detect{|o| o.table_id == table.id}
          order_times = (order.try(:times) || 0)
          order_guest_num = (order.try(:guest_num) || 0)
          order_amount = (order.try(:total) || 0)
          content << [
            table.table_zone.try(:name),
            table.name,
            order_times,
            order_guest_num,
            order_amount,
            avg(order_amount, order_times),
            avg(order_amount, order_guest_num)
          ]
        end
        content
      end

    end
  end
end
