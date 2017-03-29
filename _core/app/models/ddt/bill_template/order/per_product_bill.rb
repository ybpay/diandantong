module Ddt
  module BillTemplate
    module Order
      class PerProductBill < BillTemplate::Order::Base
        def items
          grouped_litps(order_change_log)
        end

        def render
          template = template_from_setting
          items.map do |item|
            output = replace_if_tag(template, item)
            output = replace_inline_values(output, inline_value_names)
            output = replace_item_inline_values(output, item, inline_item_value_names)
            output = output.gsub("{{item_id}}", "P#{item.line_item_id}")
            output = replace_p_tag(output)
            output
          end
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
            <M>数量:</M> <B>{{item_quantity}}</B>
            <if item_present='item_note'>
            <M>品注:</M> <B>{{item_note}}</B>
            </if>

            <if present='waiter_name'>
            点菜员: {{waiter_name}}
            </if>
            下单时间: {{placed_at}}
            流水号: {{item_id}}
          TMP
        end
      end
    end
  end
end