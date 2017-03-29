module Ddt
  module BillTemplate
    module Queue
      class EnqueueingBill < BillTemplate::Queue::Base
        def render
          output = template_from_setting
          output = replace_if_tag(output)
          output = replace_inline_values(output, inline_value_names)
          output = replace_p_tag(output)
          output
        end
        alias_method_chain :render, :error_catch

        def self.default_template
          <<-TMP.strip_heredoc

            <C>欢迎光临</C>
            <C>{{branch_name}}</C>
            <CB>{{queue_name}} {{guest_no}}</CB>
            <C>人数: {{guest_num}}</C>
            <C>还需等待: {{guest_num_at_front}}桌</C>
            <C>取号时间: {{guest_created_at}}</C>
            <C>听到叫号请到迎宾台，过号请重新取号</C>

            <if blank='user'>
            <C>微信扫描二维码，享受排队实时提醒。在家取号，到号提醒，提前点菜</C>
            {{queue_qrcode}}
            </if>\n
            {{support_info}}\n\n\n
          TMP
        end
      end
    end
  end
end