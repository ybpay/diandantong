module Ddt
  module Bill
    module Order
      class Modify < Ddt::Bill::Order::Base
        def content
          litps = order_change_log.line_item_trace_points.select {|litp|printer.is_print_all? || litp.in_white_list?(printer.white_list_product_ids)}
          return nil if litps.blank?
          # TODO: refactor me later:) be nice
          lines = deal_litps(litps, options)
          lines.map do |line|
            bill_header + line + bill_footer
          end
        end

        def options
          {note: true}
        end

        def deal_litps(litps, options = {})
          if printer.print_per_product?
            items = merge_litps(litps)
            # build lines
            new_lines = []
            items.each do |item|
              line = []
              line << "<M>名称:</M> <B>#{item[:name]}</B>"
              line << "<M>品注:</M> <B>#{item[:note]}</B>"  if options[:note] && item[:note].present?
              line << "<M>数量:</M> <B>#{item[:count]}</B>"
              line << "<M>单价:</M> <B>#{item[:price]}</B>" if options[:price] && item[:price].present?
              line << "#{order_change_log.operator_name}" if order_change_log.operator.present?
              line << "流水号: #{mark}#{item[:line_item_id]}"
              new_lines << line.join("\n")
            end
            new_lines
          elsif printer.print_one_by_one?
            new_lines = []
            litps.each_with_index do |litp, index|
              line = []
              line << "<M>名称:</M> <B>#{litp.name}</B>"
              line << "<M>品注:</M> <B>#{litp.note}</B>" if options[:note] && litp.note.present?
              line << "<M>数量:</M> <B>1</B>"
              line << "<M>单价:</M> <B>#{litp.line_item.price}</B>" if options[:price] && (litp.line_item.price rescue nil).present?
              line << "#{order_change_log.operator_name}" if order_change_log.operator.present?
              line << "流水号: #{mark}#{litp.line_item_id}#{index}"
              new_lines << line.join("\n")
            end
            new_lines
          else
            items = merge_litps(litps)
            new_lines = []
            line = ""
            items.each do |item|
              line << "\n   <B>#{item[:count]}</B> * <M>#{item[:name]}</M>"
              line << " <M>[#{item[:note]}]</M>" if options[:note] && item[:note].present?
            end
            line << "\n #{order_change_log.operator_name}" if order_change_log.operator.present?
            new_lines << line
            new_lines
          end
        end

        def merge_litps(litps)
          hash = Hash.new
          # 按 line_item 聚合
          litps.each do |litp|
            key = "#{litp.line_item_id}_#{litp.itemable_id}"
            entry = hash[key]
            if entry.present?
              entry[:count] = entry[:count] + 1
            else
              entry = {
                  line_item_id: litp.line_item_id,
                  name: litp.name,
                  price: (litp.line_item.price rescue nil),
                  count: 1,
                  note: litp.note
              }
              hash[key] = entry
            end
          end
          hash.values
        end

        def mark
          self.class.name.demodulize[0]
        end

      end
    end
  end
end
