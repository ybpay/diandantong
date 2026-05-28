module Ddt
  module Bill
    module Branch
      class WaiterList < ::Ddt::Bill::Branch::Base

        def content
          text = []
          text << "<CM>点菜员负责订单数目清单</CM>\n"
          text << "门店: #{@branch.name}"
          text << "时间: #{@start_time}"
          text << "至: #{@end_time}\n"
          text << "-"*bill_width('80')
          text << "#{'姓名'.fixed_width(8)}#{'订单数'.fixed_width(8)}#{'金额'.fixed_width(8)}#{'客单价'.fixed_width(8)}"
          items.each do |item|
            line = []
            line << item.waiter_name.fixed_width(10)
            line << item.order_quantity.fixed_width(5)
            line << item.order_sale_amount.fixed_width(9)
            line << item.average_sale_amount.fixed_width(8, float: :right)
            text << line.join
          end
          text << "-"*bill_width('80')
          text << "总计: #{total_orders_amount}"
          text << "-"*bill_width('80')
          text << "读取人员: #{@operator.name}"
          text << "读取时间: #{Time.now}"
          text.join("\n")
        end

        def items
          if @items.present?
            @items
          else
            order_quantity = OrderService::Api::Statistic.order_quantity(query: base_query, group_by: :waiter_id)
            order_sale_amount = OrderService::Api::Statistic.order_sale_amount(query: base_query, group_by: :waiter_id)
            accounts = @branch.managers.with_discarded.where(id: order_quantity.keys.map(&:to_i)).to_a
            @items = order_quantity.map do |waiter_id, quantity|
              WaiterList::Item.new({
                waiter_id: waiter_id,
                waiter_name: accounts.detect{|account| account.id == waiter_id}.try(:name),
                order_quantity: quantity,
                order_sale_amount: order_sale_amount.fetch(waiter_id, 0).round(2),
              })
            end
          end
        end

        def total_orders_amount
          @total_orders_amount ||= items.map(&:order_quantity).sum
        end

        private
        def base_query
          { branch_id_eq: branch.id, placed_at_gteq: start_time, placed_at_lteq: end_time, type_eq: "Ddt::EatInHallOrder"}
        end

        class Item
          attr_accessor :waiter_id, :waiter_name, :order_quantity, :order_sale_amount
          def initialize(params={})
            params.each do |key, value|
              self.send("#{key}=", value)
            end
          end

          def waiter_name
            @waiter_name || @waiter_id
          end

          def average_sale_amount
            (order_sale_amount / order_quantity).round(2)
          end
        end
      end
    end
  end
end
