module Ddt
  module Bill
    module Branch
      class GiftItemList < ::Ddt::Bill::Branch::Base
        def content
          text = []
          text << "<CM>赠菜清单</CM>\n"
          text << "门店: #{@branch.name}"
          text << "时间: #{@start_time}"
          text << "  至: #{@end_time}\n"
          text << "-"*bill_width('80')
          items.each do |item|
            line = []
            line << "单号: #{item.order_number}".fixed_width(20)
            line << "台号: #{item.table_name_with_zone}" if item.table_name_with_zone.present?
            text << line.join
            text << "时间: #{item.created_at}"
            text << "菜品: #{item.itemable_name}  数量: #{item.quantity} 价格: #{item.original_price}"
            text << "理由: #{item.gift_reason}\n"
          end
          text << "-"*bill_width('80')
          text << "总数: #{items.map(&:quantity).sum}"
          text << "总计: #{items.map{|i| i.original_price * i.quantity}.sum}"
          text << "-"*bill_width('80')
          text << "读取人员: #{@operator.name}"
          text << "读取时间: #{Time.now}"
          text.join("\n")
        end

        def items
          @items ||= OrderService::Api::Statistic.gift_item_list(query: {
              branch_id_eq: @branch.id, created_at_gteq: @start_time, created_at_lteq: @end_time
              }).map do |item_hash|
              GiftItemList::Item.new(item_hash)
            end
        end

        class Item
          attr_accessor :branch_id, :waiter_id, :order_number, :table_zone_name, :table_name, :created_at, :itemable_type, :itemable_id, :itemable_name, :product_name, :quantity, :original_price, :gift_reason, :order_id
          def initialize(params={})
            params.each do |key, value|
              self.send("#{key}=", value)
            end
          end

          def table_name_with_zone
            "#{table_zone_name}-#{table_name}" if table_zone_name.present?
          end
        end
      end
    end
  end
end
