module Ddt
  module BillTemplate
    module Order
      class ProductBill < BillTemplate::Order::Base
        def items
          if order_change_log.blank?
            order.line_items.active.map{|item| TagItem.new(item)}
          else
            order.line_items.by_log(order_change_log).map{|item| TagItem.new(item)}
          end
        end

        def render
          output = template_from_setting
          output = replace_item_default(output)
          item_repeat_tag = TagHelper.scan_tag(output, "item-repeat").first
          output = output.sub(item_repeat_tag.body, item_repeat_tag.render_items(items)) if item_repeat_tag.present?
          output = replace_inline_values(output, inline_value_names)
          output = replace_if_tag(output)
          output = replace_p_tag(output)
          output
        end
        alias_method :render_without_error_catch, :render
        alias_method :render, :render_with_error_catch
        def self.default_template
          <<-TMP.strip_heredoc
            <CM>点菜清单</CM>\n
            <if type='eat_in_hall'>
            <M>桌台:</M><B>{{table_name_with_zone}}</B>
            </if>
            {{hyphen_line}}
            单号: {{number}}
            <if type='eat_in_hall' present='guest_num'>
            人数: {{guest_num}}
            </if>
            <if type='eat_in_hall' present='waiter_name'>
            点菜员: {{waiter_name}}
            </if>
            {{item_title}}
            {{hyphen_line}}
            <item-repeat>
            {{item_default_template}}
            </item-repeat>
            {{hyphen_line}}
            合计: {{item_total}}\n\n\n
            读取人员：{{bill_operator_name}}\n
            <C>技术支持:点单通智慧餐饮</C>
          TMP
        end
      end
    end
  end
end