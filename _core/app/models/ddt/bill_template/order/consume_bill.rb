module Ddt
  module BillTemplate
    module Order
      class ConsumeBill < BillTemplate::Order::Base
        def items
          return @items if @items.present?
          @items = order_change_log.blank? ? order.line_items.active : order.line_items.by_log(order_change_log)
          @items = @items.map{|item|
            tag_item = TagItem.new(item)
            tag_item.item_name = "[券]#{tag_item.item_name}" if item.adjustment_total < 0 && item.coupon_adjust?
            tag_item.item_name = "[促]#{tag_item.item_name}" if item.adjustment_total < 0 && item.promotion_adjust?
            tag_item.item_name = "*#{tag_item.item_name}" if item.adjustment_total < 0 && item.discount_adjust?
            tag_item.item_name = "*#{tag_item.item_name}(赠)" if item.gift?
            tag_item
          }
          if branch.print_setting.merge_same_item?
            @items = TagItem.merge(@items)
          end
          @items
        end
        
        def print_times
          print_time = Ddt::PrintTime.find_by(order_id: order.id)
          times = 1
          if print_time.nil?
            Ddt::PrintTime.create(order_id: order.id, consume_bill_times: times)
          else
            times = print_time.consume_bill_times + 1
            print_time.update(consume_bill_times: times)
          end
          times
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
        alias_method :render_without_error_catch, :render
        alias_method :render, :render_with_error_catch
        def self.default_template
          <<-TMP.strip_heredoc
            <CM>客人就餐消费单</CM>\n
            <if type='eat_in_hall'>
            <M>桌台:</M><B>{{table_name_with_zone}}</B>
            </if>
            {{hyphen_line}}
            单号: {{number}}
            <if type='eat_in_hall' present='waiter_name'>
            点菜员: {{waiter_name}}
            </if>
            {{item_title}}
            {{hyphen_line}}
            <item-repeat>
            {{item_default_template}}
            </item-repeat>
            {{hyphen_line}}
            <if present='adjustments'>
            {{adjustments}}
            </if>
            <if type='delivery'>
            运费: {{shipment_total}}
            </if>
            <if paid='true'>
            {{pay_items}}
            </if>
            消费合计: {{consume_amount}}
            <if present='tax_total'>
            税收合计: {{tax_total}}
            </if>
            订单合计: {{original_amount}}
            折扣合计: {{discount_amount}}
            应收合计: {{amount_for_pay}}

            读取人员：{{bill_operator_name}}\n
            打印次数：{{print_times}}
          TMP
        end
      end
    end
  end
end