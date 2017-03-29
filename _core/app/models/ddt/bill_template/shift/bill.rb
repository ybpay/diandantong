module Ddt
  module BillTemplate
    module Shift
      class Bill < BillTemplate::Shift::Base
        def items
          shift.base_shift_items.select{|item| item.amount > 0}
        end

        def render
          output = template_from_setting
          repeat_tag = TagHelper.scan_tag(output, "repeat").first
          output = output.sub(repeat_tag.body, repeat_tag.render_items(items)) if repeat_tag.present?
          output = replace_inline_values(output, inline_value_names)
          output = replace_if_tag(output)
          output = replace_p_tag(output)
          output
        end
        alias_method_chain :render, :error_catch

        def self.default_template
          <<-TMP.strip_heredoc
            交班记录
              值班人:  {{shift_account_name}}
            值班开始时间: {{shift_created_at}}
            <if present="shift_closed_at">
              值班结束时间:  {{shift_closed_at}}
            </if>
            <if blank="shift_closed_at">
                      至:  {{time_now}}
            </if>
            {{hyphen_line}}
            人数: {{total_customter_count}}
            来自微信: {{order_from_wechat_count}}
            来自收银端: {{order_from_webpos_count}}
            来自App: {{order_from_app_count}}
            堂点单数: {{total_eat_in_hall_order_count}}
            人均消费: {{per_capita_consumption}}
            单均消费: {{per_eat_in_hall_order_consumption}}
            退菜数量: {{subtract_item_count}}
            退菜金额: {{total_subtract_item_amount}}
            折扣金额: {{discount_amount}}
            抹零:  {{moling_amount}}
            订单金额: {{total_amount}}
            {{hyphen_line}}
            {{shift_items_title}}
            <repeat type="shift_items">
            <if blank="not_actual_amount" lstrip=true>
            <p width=8>{{pay_method_code}}</p> <p width=8>{{pay_method_name}}</p> <p width=8>{{amount}}</p> <p width=8>{{count}}</p>
            </if>
            <if present="not_actual_amount" lstrip=true>
            <p width=8>{{pay_method_code}}</p> <p width=8>{{pay_method_name}}(实收)</p> <p width=8>{{actual_amount}}</p>
            <p width=8></p> <p width=8>{{pay_method_name}}(非实收)</p> <p width=8>{{not_actual_amount}}</p>
            </if>
            </repeat>
            {{hyphen_line}}
                  合计金额: {{total_amount}}
                非实收金额: {{not_actual_amount}}
                  未结金额: {{unpaid_amount}}
                    营业额: {{total_actual_amount}}
            <if present="recharge_amount">
            会员卡充值金额: {{recharge_amount}}
            </if>
            <if present="pre_cash_amount">
                  放入现金: {{pre_cash_amount}}
            </if>\n\n
          TMP
        end
      end
    end
  end
end
