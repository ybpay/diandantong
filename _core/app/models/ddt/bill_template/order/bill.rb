module Ddt
  module BillTemplate
    module Order
      class Bill < BillTemplate::Order::Base
        def items
          return @items if @items.present?
          @items = order.line_items.active.select{|line_item|
              printer.is_print_all || line_item.in_white_list?(printer.white_list_ids)
            }.map{|item|
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
            Ddt::PrintTime.create(order_id: order.id, bill_times: times)
          else
            times = print_time.bill_times + 1
            print_time.update(bill_times: times)
          end
          times
        end

        def render
          output = template_from_setting
          output = replace_item_default(output)
          item_repeat_tag = TagHelper.scan_tag(output, "item-repeat").first
          if item_repeat_tag.present?
            repeat_tag_output = item_repeat_tag.render_items(items)
            output = output.sub(item_repeat_tag.body, repeat_tag_output)
          end
          output = replace_if_tag(output)
          output = replace_inline_values(output, inline_value_names)
          output = replace_p_tag(output)
          output
        end
        alias_method :render_without_error_catch, :render
        alias_method :render, :render_with_error_catch
        def self.default_template
          <<-TMP.strip_heredoc
            <if paid='true'>
            <CM>结账单</CM>\n\n
            收银员: {{settle_account_name}}
            结账时间: {{paid_at}}
            </if>
            <if type='fastfood'>
            牌号: {{food_number}}
            </if>
            订单编号: {{number}}
            门店名称: {{branch_name}}
            下单来源: {{place_type_name}}
            下单时间: {{placed_at}}
            订单状态: {{state_name}}
            <if canceled='true'>
            取消原因: {{cancel_reason}}
            </if>
            订单类型: {{type_name}}
            支付方式: {{pay_method_name}}
            支付状态: {{pay_item_state_name}}
            <if vip='true'>
            会员信息: {{vip_info}}
            </if>
            备注: {{note}}
            <if type='delivery'>
            联系方式: {{delivery_contact_info}}
            配送地址: {{delivery_address_info}}
            配送时间: {{delivery_datetime}}
            配送员: {{delivery_man_info}}
            </if>
            <if type='delivery' from='Wechat'>
            距离店铺距离(系统猜测距离，仅供参考): {{delivery_distance}}
            </if>
            <if type='eat_in_hall'>
            桌台信息: {{table_name_with_zone}}
            用餐人数: {{guest_num}}
            点菜员: {{waiter_name}}
            </if>
            <if type='reservation'>
            预订人信息: {{reservation_customer_info}}
            预定时间: {{reservation_time_info}}
            预订备注: {{reservation_note}}
            </if>
            <if present='user'>
            累计下单数量: {{user_placed_orders_count}}
            </if>
            <if present='form_contents'>
            {{form_contents}}
            </if>
            <if present='line_items'>
            {{item_title}}
            {{hyphen_line}}
            <item-repeat>
            {{item_default_template}}
            </item-repeat>
            {{hyphen_line}}
            </if>
            <if present='adjustments'>
            {{adjustments}}
            </if>
            <if present='moling_amount'>
            抹零: {{moling_amount}}
            </if>
            <if type='delivery'>
            运费: {{shipment_total}}
            </if>
            {{pay_items}}
            消费合计: {{consume_amount}}
            <if present='tax_total'>
            税收合计: {{tax_total}}
            </if>
            订单合计: {{original_amount}}
            折扣合计: {{discount_amount}}
            应收合计: {{amount_for_pay}}
            <if present="vip_card_no">
            会员卡号: {{vip_card_no}}
            会员卡余额: {{vip_card_amount}}
            </if>
            <if present="tick_account">
            挂账单位:{{tick_account}}\n
            挂账人签名:\n
            </if>
            {{pcn_qrcode}}
            {{open_cashbox}}
            读取人员：{{bill_operator_name}}\n
            打印次数：{{print_times}}
            <C>技术支持:点单通智慧餐饮</C>
          TMP
        end

      end
    end
  end
end