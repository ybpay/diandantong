#encoding: utf-8
module Ddt
  module Bill
    module Queue
      class PreOrder < Ddt::Bill::Queue::Base
        def content
          pre_order_itemables = guest_queue.pre_order_itemables
          bill = []
          bill << "\n"
          bill << "<CB>预点菜记录</CB>"
          bill << "<CB>#{queue_setting.name} #{guest_queue.guest_no}</CB>"
          bill << "<C>人数: #{guest_queue.guest_num}</C>"
          bill << "<C>排号时间: #{guest_queue.created_at.strftime("%F %T")}</C>"
          bill << "<C>等待时间: #{guest_queue.waited_time_str}</C>"
          bill << "\n"
          if pre_order_itemables.size > 0
            bill << item_title
            bill << "－" * (bill_width(spec)/2)
            pre_order_itemables.each do |order_itemable|
              bill << format_item(order_itemable)
            end
            bill << "－" * (bill_width(spec)/2)
          end
          bill.compact.join("\n") + "\n\n\n"
        end

        private
        def item_title
          if spec == '58'
            # 32 = 4*2 + 12 + 2*2 + 4 + 2*2
            "商品名称            数量    小计"
          else
            # 40 = 4*2 + 18 + 2*2 + 6 + 2*2
            "商品名称                  数量      小计"
          end
        end

        def format_item(order_itemable)
          name = order_itemable.name
          amount = order_itemable.amount
          quantity = order_itemable.quantity
          result = []
          name_array = []
          if spec == '58'
            # 32 = 20 + 4 + 8
            name_array = item_name_split(name, 19)
            result << "#{format_string_with_escape(20, name_array[0])}%3d %7.2f " % [quantity, amount]
          else
            # 40 = 26 + 4 + 10
            name_array = item_name_split(name, 25)
            result << "#{format_string_with_escape(26, name_array[0])}%3d %9.2f " % [quantity, amount]
          end
          result << name_array[1..-1].map{|n| " #{n}"}.join("\n") if name_array.size > 1
          result.join("\n")
        end

        def spec
          printer.print_spec.to_s
        end
      end
    end
  end
end
