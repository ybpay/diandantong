module Ddt
  module BillTemplate
    module Shift
      class RechargeBill < BillTemplate::Shift::Base
        def items
          shift.recharge_shift_items.select{|item| item.amount > 0}
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
            会员充值记录
                门店: {{branch_name}}
              值班人:  {{shift_account_name}}
            值班开始时间: {{shift_created_at}}
            <if present="shift_closed_at">
              值班结束时间:  {{shift_closed_at}}
            </if>
            <if blank="shift_closed_at">
                      至:  {{time_now}}
            </if>
            {{hyphen_line}}
            {{shift_items_title}}
            {{hyphen_line}}
            <repeat type="shift_items">
            <p width=8>{{pay_method_code}}</p> <p width=8>{{pay_method_name}}</p> <p width=8>{{amount}}</p> <p width=8>{{count}}</p>
            <if present="not_actual_amount">
            <p width=8></p> <p width=8>{{pay_method_name}}(实收)</p> <p width=8>{{actual_amount}}</p>
            <p width=8></p> <p width=8>{{pay_method_name}}(非实收)</p> <p width=8>{{not_actual_amount}}</p>
            </if>
            </repeat>
            {{hyphen_line}}
                  充值单数: {{recharge_order_count}}
                  充值金额: {{recharge_amount}}
                  充值赠送金额: {{recharge_extra_amount}}
                  会员消费金额: {{vip_card_pay_amount}}
            \n\n
          TMP
        end
      end
    end
  end
end
