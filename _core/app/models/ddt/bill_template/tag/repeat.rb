module Ddt
  module BillTemplate
    module Tag
      class Repeat < Tag::Base
        tag_attr :type, :string

        def render_items(items)
          items.map do |item|
            output = content
            repeat_tags = TagHelper.scan_tag(output, "repeat")
            repeat_tags.each do |repeat_tag|
              item_items_method_name = repeat_tag.type
              if item.respond_to?(item_items_method_name)
                item_items = item.try(item_items_method_name)
              else
                item_items = item.items
              end
              output = output.sub(repeat_tag.body, repeat_tag.render_items(item_items))
            end
            output = replace_if_tag(output, item)
            output = replace_item_inline_values(output, item, inline_value_names)
            output = TagHelper.replace_p_tag(output)
            output
          end.join("\n")
        end

        private
        def inline_value_names
          case type.to_sym
          when :shift_group
            [
              :name,
              :total_customter_count,
              :total_eat_in_hall_order_count,
              :per_capita_consumption,
              :per_eat_in_hall_order_consumption,
              :subtract_item_count,
              :total_subtract_item_amount,
              :order_from_wechat_count,
              :order_from_webpos_count,
              :order_from_app_count,
              :recharge_amount,
              :recharge_order_count,
              :recharge_extra_amount,
              :vip_card_pay_amount,
              :exchange_amount,
              :discount_amount,
              :moling_amount,
              :unpaid_amount,
              :total_amount,
              :not_actual_amount,
              :unpaid_amount,
              :total_actual_amount,
            ]
          when :shift_items, :shift_recharge_items
            [
              :pay_method_code,
              :pay_method_name,
              :amount,
              :pay_method_name,
              :cash_amount,
              :pay_method_name,
              :extra_amount,
              :actual_amount,
              :unpaid_amount,
              :not_actual_amount,
              :count,
            ]
          else
            []
          end
        end

        def replace_if_tag(text, item)
          replaced_text = text
          if_tags = TagHelper.scan_tag(text, "if")
          if_tags.each do |tag|
            replaced_text = replaced_text.sub(tag.body, tag.render(item))
          end
          replaced_text
        end

        def replace_item_inline_values(text, item, names)
          output = text
          names.each do |name|
            output = output.gsub("{{#{name}}}", "#{item.send(name)}") if output.include?("{{#{name}}}") && item.respond_to?(name, true)
          end
          output
        end
      end
    end
  end
end