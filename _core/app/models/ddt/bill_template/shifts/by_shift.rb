module Ddt
  module BillTemplate
    module Shifts
      class ByShift < BillTemplate::Shifts::Base
        def items
          shift_list.items
        end

        def render
          output = template_from_setting
          repeat_tag = TagHelper.scan_tag(output, "repeat").first
          output = output.sub(repeat_tag.body, repeat_tag.render_items(items)) if repeat_tag.present?
          output = replace_if_tag(output)
          output = replace_inline_values(output, inline_value_names)
          output = replace_p_tag(output)
          output
        end
        alias_method_chain :render, :error_catch

        def self.default_template
          <<-TMP.strip_heredoc
            <CM>交班汇总</CM>

            店铺: {{branch_name}}
            时间: {{start_time}}
              至: {{end_time}}\n\n
            <repeat type="shift_group">
            {{name}}
            ----------------------------------------
            <p width=10 align=right>消费人数</p>:<p width=8 align=left>{{total_customter_count}}</p>   <p width=10 align=right>堂点单数</p>:<p width=8 align=left>{{total_eat_in_hall_order_count}}</p>
            <p width=10 align=right>人均</p>:<p width=8 align=left>{{per_capita_consumption}}</p>   <p width=10 align=right>单均</p>:<p width=8 align=left>{{per_eat_in_hall_order_consumption}}</p>
            <p width=10 align=right>退单数</p>:<p width=8 align=left>{{subtract_item_count}}</p>   <p width=10 align=right>退单额</p>:<p width=8 align=left>{{total_subtract_item_amount}}</p>
            <p width=10 align=right>来自微信</p>:<p width=8 align=left>{{order_from_wechat_count}}</p>   <p width=10 align=right>来自收银</p>:<p width=8 align=left>{{order_from_webpos_count}}</p>
            <p width=10 align=right>来自App</p>:<p width=8 align=left>{{order_from_app_count}}</p>   <p width=10 align=right>充值金额</p>:<p width=8 align=left>{{recharge_amount}}</p>
            <p width=10 align=right>兑换金额</p>:<p width=8 align=left>{{exchange_amount}}</p>   <p width=10 align=right>折扣金额</p>:<p width=8 align=left>{{discount_amount}}</p>
            <p width=10 align=right>抹零调整</p>:<p width=8 align=left>{{moling_amount}}</p>   <p width=10 align=right>订单总额</p>:<p width=8 align=left>{{total_amount}}</p>
            ----------------------------------------
            <p width=8>科目代码</p> <p width=16>支付方式</p> <p width=8>支付金额</p>
            ----------------------------------------
            <repeat type="shift_items">
            <if blank="not_actual_amount" lstrip=true>
            <p width=8>{{pay_method_code}}</p> <p width=16>{{pay_method_name}}</p> <p width=8>{{amount}}</p>
            </if>
            <if present="not_actual_amount" lstrip=true>
            <p width=8>{{pay_method_code}}</p> <p width=16>{{pay_method_name}}(实收)</p> <p width=8>{{actual_amount}}</p>
            <p width=8></p> <p width=16>{{pay_method_name}}(非实收)</p> <p width=8>{{not_actual_amount}}</p>
            </if>
            </repeat>
            ----------------------------------------
                  合计金额: {{total_amount}}
                  非实收金额: {{not_actual_amount}}
                  未结算金额: {{unpaid_amount}}
                  营业额: {{total_actual_amount}}\n
            ----------------------------------------
            <p width=8>科目代码</p> <p width=16>支付方式</p> <p width=8>支付金额</p>
            ----------------------------------------
            <repeat type="shift_recharge_items">
            <if blank="not_actual_amount" lstrip=true>
            <p width=8>{{pay_method_code}}</p> <p width=16>{{pay_method_name}}</p> <p width=8>{{amount}}</p>
            </if>
            <if present="not_actual_amount" lstrip=true>
            <p width=8>{{pay_method_code}}</p> <p width=16>{{pay_method_name}}(实收)</p> <p width=8>{{actual_amount}}</p>
            <p width=8></p> <p width=16>{{pay_method_name}}(非实收)</p> <p width=8>{{not_actual_amount}}</p>
            </if>
            </repeat>
            ----------------------------------------
                  充值单数: {{recharge_order_count}}
                  充值金额: {{recharge_amount}}
                  充值赠送金额: {{recharge_extra_amount}}
                  会员消费金额: {{vip_card_pay_amount}}
            </repeat>
            读取人员: {{operator_name}}
            读取时间: {{time_now}}
          TMP
        end
      end
    end
  end
end
