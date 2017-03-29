module Ddt
  module BillTemplate
    module Order
      class AppendProductBill < BillTemplate::Order::Base
        def items
          last_append_itemable_log = order.order_change_logs.append_itemable.last
          if last_append_itemable_log.present?
            @items ||= order.line_items.active.by_log(last_append_itemable_log).map{|item| TagItem.new(item)}
          else
            []
          end
        end

        def render
          output = template_from_setting
          output = replace_item_default(output)
          item_repeat_tag = TagHelper.scan_tag(output, "item-repeat").first
          output = output.sub(item_repeat_tag.body, item_repeat_tag.render_items(items)) if item_repeat_tag.present?
          output = replace_if_tag(output)
          output = replace_inline_values(output, inline_value_names)
          output = replace_p_tag(output)
          output
        end
        alias_method_chain :render, :error_catch

        def self.default_template
          <<-TMP.strip_heredoc
            <CM>最新一次加菜清单</CM>\n
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
            备注: {{change_note}}
            {{item_title}}
            {{hyphen_line}}
            <item-repeat>
            {{item_default_template}}
            </item-repeat>
            {{hyphen_line}}\n\n\n\n
          TMP
        end

        def append_log
          order.order_change_logs.append_itemable.last
        end

        delegate :operator_name, to: :append_log
        def changed_at
          append_log.created_at.strftime("%F %T")
        end

        def change_note
          append_log.description
        end

        def base_order_inline_value_names
          super + [:changed_at, :operator_name, :change_note]
        end
      end
    end
  end
end