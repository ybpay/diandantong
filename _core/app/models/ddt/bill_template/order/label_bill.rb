module Ddt
  module BillTemplate
    module Order
      class LabelBill < BillTemplate::Order::Base
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
              output = replace_p_tag(output)
              output
            end
          end.flatten
        end
        alias_method :render_without_error_catch, :render
        alias_method :render, :render_with_error_catch
        def self.default_template
          <<-TMP.strip_heredoc

            {{item_name}} ({{index}}/{{item_quantity}})
            <if item_present='item_note'>
            {{item_note}}
            </if>
            <if type='eat_in_hall'>
            桌号: {{table_name_with_zone}} 价格: {{item_price}}
            </if>
            <if type='fastfood'>
            牌号: {{food_number}} 价格: {{item_price}}
            </if>
            单号: {{number}}
            {{placed_at}}
          TMP
        end
      end
    end
  end
end