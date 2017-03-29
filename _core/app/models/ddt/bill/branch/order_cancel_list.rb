module Ddt
  module Bill
    module Branch
      class OrderCancelList < Ddt::Bill::Branch::Base

        def content
          text = []
          text << "<CM>订单取消记录</CM>\n"
          text << "门店: #{@branch.name}"
          text << "时间: #{@start_time}"
          text << "至: #{@end_time}"
          text << "-"*bill_width('80')
          items.each do |item|
            line = []
            line << "订单编号: #{item.order_number}"
            line << "订单类型: #{item.order_type_name}"
            line << "金额: #{item.order_total}"
            line << "桌台: #{item.order_table_name_with_zone}" if item.order_table_name_with_zone
            line << "时间: #{item.created_at.strftime('%F %T')}"
            line << "操作者: #{item.operator_name}\n"
            text << line.join("\n")
          end
          text << "-"*bill_width('80')
          text << "读取人员: #{@operator.name}"
          text << "读取时间: #{Time.now}"
          text.join("\n")
        end

        def items
          @items ||= OrderService::Api::Statistic.order_change_list(query: {
              type_eq: "Ddt::OrderChangeLog::OrderCancel",
              branch_id_eq: @branch.id,
              created_at_gteq: start_time,
              created_at_lteq: end_time
            }).map{|item| OrderCancelList::Item.new(item)}
        end

        class Item
          attr_accessor :type, :created_at, :order_id, :description, :operator_name, :order_number, :order_type, :order_total, :order_table_name, :order_table_zone_name
          def initialize(params={})
            params.each do |key, value|
              self.send("#{key}=", value)
            end
          end

          def order_table_name_with_zone
            [order_table_zone_name, order_table_name].compact.join("-")
          end

          def order_type_name
            OrderService::Order::Base.type_name(order_type)
          end
        end
      end
    end
  end
end
