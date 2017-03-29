module Ddt
  module BillTemplate
    module Tag
      class ItemRepeat < Tag::Base
        tag_attr :size, :string, default: 'normal'

        def render_items(items, options={})
          tag_names = options.fetch(:tag_names, %W[item-name item-quantity item-price item-subtotal item-subtotal-after-discount])
          combo_expand = options.fetch(:combo_expand, true)
          item_name_tag     = TagHelper.scan_tag(content, "item-name").first      if tag_names.include?("item-name")
          item_quantity_tag = TagHelper.scan_tag(content, "item-quantity").first  if tag_names.include?("item-quantity")
          item_price_tag    = TagHelper.scan_tag(content, "item-price").first     if tag_names.include?("item-price")
          item_subtotal_tag = TagHelper.scan_tag(content, "item-subtotal").first  if tag_names.include?("item-subtotal")
          item_subtotal_after_discount_tag = TagHelper.scan_tag(content, "item-subtotal-after-discount").first  if tag_names.include?("item-subtotal-after-discount")
          all_lines = items.map do |item|
            lines = []
            if item.is_combo_package?
              line = content
              line_item_name = combo_expand ? item.item_product_name : item.item_name
              line = line.sub(item_name_tag.body,     item_name_tag.render(line_item_name, item.item_note)) if item_name_tag.present?
              line = line.sub(item_quantity_tag.body, item_quantity_tag.render(item.item_quantity))   if item_quantity_tag.present?
              line = line.sub(item_price_tag.body,    item_price_tag.render(item.item_price))         if item_price_tag.present?
              line = line.sub(item_subtotal_tag.body, item_subtotal_tag.render(item.item_subtotal))   if item_subtotal_tag.present?
              line = line.sub(item_subtotal_after_discount_tag.body, item_subtotal_after_discount_tag.render(item.item_subtotal_after_discount))   if item_subtotal_after_discount_tag.present?
              inline_item_value_names.each do |value_name|
                line = line.gsub("{{#{value_name}}}", "#{item.send(value_name)}")
              end
              lines << line
              lines += item_name_tag.render_overflow(line_item_name, item.item_note) if item_name_tag.present?
              if combo_expand
                item.itemable.each_item do |variant, quantity|
                  line = content
                  item_name = "  ├#{variant.name_with_options_text}"
                  line = line.sub(item_name_tag.body,     item_name_tag.render(item_name))    if item_name_tag.present?
                  line = line.sub(item_quantity_tag.body, item_quantity_tag.render(quantity)) if item_quantity_tag.present?
                  line = line.sub(item_price_tag.body,    item_price_tag.render_empty)        if item_price_tag.present?
                  line = line.sub(item_subtotal_tag.body, item_subtotal_tag.render_empty)     if item_subtotal_tag.present?
                  line = line.sub(item_subtotal_after_discount_tag.body, item_subtotal_after_discount_tag.render_empty)   if item_subtotal_after_discount_tag.present?
                  lines << line
                  lines += item_name_tag.render_overflow(item_name) if item_name_tag.present?
                end
              end
            else
              line = content
              line = line.sub(item_name_tag.body,     item_name_tag.render(item.item_name, item.item_note)) if item_name_tag.present?
              line = line.sub(item_quantity_tag.body, item_quantity_tag.render(item.item_quantity)) if item_quantity_tag.present?
              line = line.sub(item_price_tag.body,    item_price_tag.render(item.item_price))       if item_price_tag.present?
              line = line.sub(item_subtotal_tag.body, item_subtotal_tag.render(item.item_subtotal)) if item_subtotal_tag.present?
              line = line.sub(item_subtotal_after_discount_tag.body, item_subtotal_after_discount_tag.render(item.item_subtotal_after_discount))   if item_subtotal_after_discount_tag.present?
              inline_item_value_names.each do |value_name|
                line = line.gsub("{{#{value_name}}}", "#{item.send(value_name)}")
              end
              lines << line
              lines += item_name_tag.render_overflow(item.item_name, item.item_note) if item_name_tag.present?
            end
            lines
          end.flatten
          case size
          when 'N', 'n', 'normal'
            all_lines.join("\n")
          when 'M', 'm', 'medium'
            all_lines.map{|line| "<M>#{line}</M>"}.join("\n")
          when 'B', 'b', 'big'
            all_lines.map{|line| "<B>#{line}</B>"}.join("\n")
          else
            all_lines.join("\n")
          end
        end

        private
        def inline_item_value_names
          [:item_name, :item_quantity, :item_price, :item_subtotal, :item_note]
        end
      end
    end
  end
end