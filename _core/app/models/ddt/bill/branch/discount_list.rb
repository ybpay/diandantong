module Ddt
  module Bill
    module Branch
      class DiscountList < ::Ddt::Bill::Branch::Base
        def content
          text = []
          text << "<CM>折扣清单</CM>\n"
          text << "门店: #{@branch.name}"
          text << "时间: #{@start_time}"
          text << "至: #{@end_time}\n"
          text << "-"*bill_width('80')
          items.each do |item|
            line = []
            line << "订单号: #{item.order_number}".fixed_width(25)
            line << "桌台: #{item.table_name}" if item.table_name.present?
            text << line.join

            text << "时间: #{item.created_at}"

            line = []
            line << "折扣类型: #{item.label}".fixed_width(25)
            line << "折扣金额: #{item.amount}".fixed_width(20)
            text << line.join

            line = []
            line << "操作人: #{item.operator_name}".fixed_width(20)
            line << "授权人: #{item.authorizer_name}".fixed_width(20)
            text << line.join

            text << ""
          end
          text << "-"*bill_width('80')
          text << "金额总计: #{total_discount_amount}"
          text << "-"*bill_width('80')
          text << "读取人员: #{@operator.name}"
          text << "读取时间: #{Time.now}"
          text.join("\n")
        end

        def items
          @items ||= OrderService::Api::Statistic.order_discount_list(query: base_query_params).map do |item|
            Bill::Branch::DiscountList::Item.new(item)
          end
        end

        def total_discount_amount
          @total_discount_amount ||= items.map(&:amount).sum.round(2)
        end

        private
        def base_query_params
          { created_at_gteq: start_time, created_at_lteq: end_time, branch_id_eq: @branch.id }
        end

        class Item
          attr_accessor :reason, :label, :amount, :created_at, :operator_id, :authorizer_id, :order_number, :order_table_name, :order_table_zone_name
          def initialize(params={})
            params.each do |key, value|
              self.send("#{key}=", value)
            end
          end

          def operator_name
            Account.find_by(id: operator_id).try(:name)
          end

          def authorizer_name
            Account.find_by(id: authorizer_id).try(:name)
          end

          def table_name
            [order_table_zone_name, order_table_name].compact.join("-")
          end

          def created_at
            @created_at.strftime("%F %T")
          end
        end
      end
    end
  end
end
