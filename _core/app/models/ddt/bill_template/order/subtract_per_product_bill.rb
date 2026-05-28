module Ddt
  module BillTemplate
    module Order
      class SubtractPerProductBill < BillTemplate::Order::Base
        include BaseChangeBill
        def items
          subtract_items
        end

        def render
          template = template_from_setting
          items.map do |item|
            output = replace_if_tag(template, item)
            output = replace_inline_values(output, inline_value_names)
            output = replace_item_inline_values(output, item, inline_item_value_names)
            output = output.gsub("{{item_id}}", "S#{item.line_item_id}")
            output = replace_p_tag(output)
            output
          end
        end
        alias_method :render_without_error_catch, :render
        alias_method :render, :render_with_error_catch
        def self.default_template
          <<-TMP.strip_heredoc
            <CB>退菜</CB>\n
            订单号: {{number}}
            <if type='eat_in_hall'>
            <M>桌台信息:</M> <B>{{table_name_with_zone}}</B>
            </if>
            取消商品:
            <M>名称:</M> <B>{{item_name}}</B>
            <if item_present='item_note'>
            <M>品注:</M> <B>{{item_note}}</B>
            </if>
            <M>数量:</M> <B>{{item_quantity}}</B>
            <M>单价:</M> <B>{{item_price}}</B>\n
            {{operator_name}}
            流水号: {{item_id}}
            取消时间: {{changed_at}}\n
          TMP
        end
      end
    end
  end
end