module Ddt
  module BillTemplate
    module Order
      class SubtractBill < BillTemplate::Order::Base
        include BaseChangeBill
        def items
          subtract_items
        end

        def render
          if items.present?
            output = template_from_setting
            output = replace_item_default(output)
            item_repeat_tag = TagHelper.scan_tag(output, "item-repeat").first
            output = output.sub(item_repeat_tag.body, item_repeat_tag.render_items(items, combo_expand: false)) if item_repeat_tag.present?
            output = replace_if_tag(output)
            output = replace_inline_values(output, inline_value_names)
            output = replace_p_tag(output)
            output
          end
        end
        alias_method_chain :render, :error_catch

        def self.default_template
          <<-TMP.strip_heredoc
            <CB>退菜</CB>\n
            订单号: {{number}}
            <if type='eat_in_hall'>
            <M>桌台信息:</M> <B>{{table_name_with_zone}}</B>
            </if>
            取消商品:
            <item-repeat lstrip=false>

               <B>{{item_quantity}}</B> * <M>{{item_name}}</M> <M>{{item_note}}</M>
            </item-repeat>\n\n
            {{operator_name}}
            取消原因: {{subtract_reason}}
            取消时间: {{changed_at}}\n
          TMP
        end

      end
    end
  end
end