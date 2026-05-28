module Ddt
  module Bill
    module Branch
      class SubtractItemList < ::Ddt::Bill::Branch::Base

        def content
          text = []
          # text << "<pre>"
          text << "<CM>退菜清单</CM>\n"
          text << "门店: #{@branch.name}"
          text << "时间: #{@start_time}"
          text << "  至: #{@end_time}\n"
          text << "-"*bill_width('80')
          items.each do |item|
            line = []
            line << "订单号: #{item.order_number}".fixed_width(20)
            line << "桌台: #{item.table_name_with_zone}" if item.table_name_with_zone.present?
            text << line.join

            text << "时间: #{item.created_at}"

            line = []
            line << "收款员: #{item.settle_account_name}".fixed_width(20)
            line << "退单人: #{item.operator_name}"
            text << line.join

            line = []
            line << "菜品: #{item.itemable_name}".fixed_width(20)
            line << "数量: #{item.quantity}".fixed_width(10)
            line << "金额: #{item.amount}"
            text << line.join

            text << "理由: #{item.subtract_reason}"
            text << ""
          end
          text << "-"*bill_width('80')
          text << "数量总计: #{total_quantity}"
          text << "金额总计: #{total_amount}"
          text << "-"*bill_width('80')
          text << "读取人员: #{@operator.name}"
          text << "读取时间: #{Time.now}"
          text.join("\n")
        end

        def total_quantity
          items.map(&:quantity).sum
        end

        def total_amount
          items.map(&:amount).sum.round(2)
        end

        def items
           @items ||= SubtractItemList::Item.init_list(OrderService::Api::Statistic.subtract_item_list(query: {
                branch_id_eq: @branch.id, created_at_gteq: @start_time, created_at_lteq: @end_time
              }))
        end

        class Item
          attr_accessor :order_id, :order_number, :table_name, :table_zone_name, :placed_at, :created_at,
                      :itemable_type, :itemable_id, :itemable_name, :product_name, :quantity, :price, :subtract_reason
          attr_accessor :operator_id, :operator_type, :settle_account_id, :operator_name, :settle_account, :source_line_item_id

          def initialize(params={})
            params.each do |key, value|
              self.send("#{key}=", value)
            end
          end

          def table_name_with_zone
            "#{table_zone_name}-#{table_name}" if table_zone_name.present?
          end

          def settle_account_name
            settle_account.try(:name)
          end

          def amount
            price * quantity
          end

          def self.init_list(item_attrs)
            item_attrs = item_attrs.map(&:symbolize_keys)
            account_ids = item_attrs.map{|item| item[:settle_account_id]}.flatten.compact.uniq
            accounts = Account.where(id: account_ids).to_a
            item_attrs.each do |item|
              item[:settle_account] = accounts.detect{|account| account.id == item[:settle_account_id]}
            end
            item_attrs.map{ |p| self.new(p) }
          end
        end

        concerning :OldQueryMethod do
          def _items
            return @items if @items.present?
            # 从 line_item_trace_points 里找到所有退菜
            line_item_trace_points = @branch.line_item_trace_points.includes(:order).references(:ddt_orders)
                                         .includes(:order_change_log).references(:ddt_order_change_logs)
                                         .where(ddt_orders: {paid_at: @start_time..@end_time},
                                                ddt_order_change_logs: {type: 'Ddt::OrderChangeLog::DeleteItemable'}
                                         )
            @items= map_as_line_items(line_item_trace_points)
          end

          private
          # 聚合为 line_item 形式
          # 这个以后需要抽取公共模块，但不同的场景，有不同的结果与聚合键，如何处理？
          def map_as_line_items(litps)
            hash = Hash.new
            # 按 line_item 聚合
            litps.each do |litp|
              # 按批次、LineItem 聚合
              key = "#{litp.line_item_id}_#{litp.itemable_id}_#{litp.order_change_log_id}"

              entry = hash[key]
              if entry.present?
                entry[:count] = entry[:count] + 1
              else
                note_str = litp.note.present? ? "[#{litp.note}]" : ""
                entry = {
                    order_number: litp.order.number,
                    table_name: litp.order.try(:table).try(:name_with_zone),
                    created_at: litp.created_at.strftime("%Y-%m-%d %H:%M:%S"),
                    name: "#{litp.name}#{note_str}",
                    count: 1,
                    price: litp.itemable_with_discarded.price,  # 如果是套餐，这个价格只有参考意义
                    # note: litp.note,
                    reason: litp.order_change_log.description,
                    operator_name: litp.order_change_log.operator.try(:name),
                    payee_name: litp.order.order_change_logs.where(type: "Ddt::OrderChangeLog::OrderPay").first.try(:operator).try(:name)
                }
                hash[key] = entry
              end
            end
            hash.values
          end
        end
      end
    end
  end
end
