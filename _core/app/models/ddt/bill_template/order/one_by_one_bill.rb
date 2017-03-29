module Ddt
  module BillTemplate
    module Order
      class OneByOneBill < BillTemplate::Order::Base
        def items
          grouped_litps(order_change_log)
        end

        def render
          template = template_from_setting
          items.map do |item|
            (1..item.item_quantity).to_a.map do |index|
              output = replace_if_tag(template, item)
              output = replace_inline_values(output, inline_value_names)
              output = replace_item_inline_values(output, item, inline_item_value_names)
              output = output.gsub("{{index}}", "#{index}")
              output = output.gsub("{{item_id}}", "I#{item.line_item_id}#{index}")
              output = replace_p_tag(output)
              output
            end
          end.flatten
        end
        alias_method_chain :render, :error_catch

        def self.default_template
          <<-TMP.strip_heredoc
            订单编号: {{number}}
            订单类型: {{type_name}}
            <if type="eat_in_hall">
            <M>桌台信息</M>: <B>{{table_name_with_zone}}</B>
            </if>
            <if type="fastfood">
            牌号: {{food_number}}
            </if>
            <if present='note'>
            备注: {{note}}
            </if>
            <if present="form_contents">
            {{form_contents}}
            </if>
            <M>名称:</M> <B>{{item_name}}</B>
            <M>数量:</M> <B>1</B>
            <if item_present='item_note'>
            <M>品注:</M> <B>{{item_note}}</B>
            </if>

            <if present='waiter_name'>
            点菜员: {{waiter_name}}
            </if>
            下单时间: {{placed_at}}
            流水号: {{item_id}}
          TMP
          # n.times do |i|
          #   bill = []
          #   bill << "订单编号: #{order.number}"
          #   bill << "订单类型: #{order.type_name}"
          #   bill << order.short_addition_info.map(&format_info).join("\n")
          #   bill << "<M>名称:</M> <B>#{order_item[:name]}</B>"
          #   bill << "<M>数量:</M> <B>1</B>"
          #   bill << "<M>品注:</M> <B>#{order_item[:note]}</B>" if order_item[:note].present?
          #   bill << "\n"
          #   bill << "点菜员: #{order.waiter.name}" if order.waiter.present?
          #   bill << "下单时间: #{order.placed_at.try(:strftime, '%F %T')}"
          #   bill << "流水号: I#{order_item[:line_item_id]}#{i}"
          #   bills << bill.join("\n")
          # end
        end

        def inline_item_value_names
          [:item_name, :item_note]
        end
      end
    end
  end
end