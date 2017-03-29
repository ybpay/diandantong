module Ddt
  module BillTemplate
    module Queue
      class PreOrderBill < BillTemplate::Queue::Base
        def items
          guest_queue.pre_order_itemables.map(&:to_line_itemable).map{|item| TagItem.new(item)}
        end

        def render
          output = template_from_setting
          output = replace_item_default(output)
          output = replace_if_tag(output)
          item_repeat_tag = TagHelper.scan_tag(output, "item-repeat").first
          output = output.sub(item_repeat_tag.body, item_repeat_tag.render_items(items)) if item_repeat_tag.present?
          output = replace_inline_values(output, inline_value_names)
          output = replace_p_tag(output)
          output
        end
        alias_method_chain :render, :error_catch

        def self.default_template
          <<-TMP.strip_heredoc

            <CB>预点菜记录</CB>
            <CB>{{queue_name}} {{guest_no}}</CB>
            <C>人数: {{guest_num}}</C>
            <C>排号时间: {{guest_created_at}}</C>
            <C>等待时间: {{guest_waited_time}}</C>

            {{item_title}}
            {{hyphen_line}}
            <item-repeat>
            {{item_default_template}}
            </item-repeat>
            {{hyphen_line}}
          TMP
        end

        def replace_item_default(text)
          replace_text =
            case bill_width
            when 32
              "<item-name width=20 align='left'/><item-quantity width=3 align='right'/>"
              # "<item-name width=20 align='left'/><item-quantity width=3 align='right'/> <item-subtotal width=7 scale=2 align='right'/> "
            when 40
              "<item-name width=26 align='left'/><item-quantity width=3 align='right'/>"
              # "<item-name width=26 align='left'/><item-quantity width=3 align='right'/> <item-subtotal width=9 scale=2 align='right'/> "
            end
          text.gsub("{{item_default_template}}", replace_text)
        end
      end
    end
  end
end