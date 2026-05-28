module Ddt
  module BillTemplate
    module Order
      class ShortBill < BillTemplate::Order::Base
        def items
          @items ||= grouped_litps(order_change_log)
        end

        def render
          if items.present?
            output = template_from_setting
            output = replace_item_default(output)
            item_repeat_tag = TagHelper.scan_tag(output, "item-repeat").first
            output = output.sub(item_repeat_tag.body, item_repeat_tag.render_items(items)) if item_repeat_tag.present?
            output = replace_if_tag(output)
            output = replace_inline_values(output, inline_value_names)
            output = replace_p_tag(output)
            output
          end
        end
        alias_method :render_without_error_catch, :render
        alias_method :render, :render_with_error_catch
        def self.default_template
          <<-TMP.strip_heredoc
            订单编号: {{number}}
            订单类型: {{type_name}}
            <if present='waiter_name'>
            点菜员: {{waiter_name}}
            </if>
            <if present='note'>
            备注: {{note}}
            </if>
            <if present='form_contents'>
            {{form_contents}}
            </if>
            <if type='eat_in_hall'>
            桌台信息: {{table_name_with_zone}}
            </if>
            <if type='fastfood'>
            牌号: {{food_number}}
            </if>
            <item-repeat lstrip=false>

                <M>{{item_name}} * </M><B>{{item_quantity}}</B> {{item_note}}
            </item-repeat>\n\n\n
          TMP
        end
      end
    end
  end
end