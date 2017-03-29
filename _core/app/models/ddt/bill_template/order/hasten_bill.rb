module Ddt
  module BillTemplate
    module Order
      class HastenBill < BillTemplate::Order::Base
        def self.preview(branch)
          printer = Printer::Normal.new(print_spec: "58", use_scene: :webpos)
          order = virtual_order_of_branch(branch)
          event = Ddt::Notification::Event::Order::Hasten.new({
            track_from: "FromWebpos",
            created_at: Time.now,
            })
          self.new(order: order, printer: printer, event: event).render
        end

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
            <CB>催菜</CB>\n
            <if type='eat_in_hall'>
            <M>桌台: </M><B>{{table_name_with_zone}}</B>
            </if>
            <if type='fastfood'>
            <M>牌号: </M><B>{{food_number}}</B>
            </if>
            <if type='delivery'>
            <M>联系人: </M><B>{{delivery_contact_info}}</B>
            <M>地址: </M><B>{{delivery_address_info}}</B>
            </if>
            <CB>催整单</CB>
            来源: {{event_track_from}}
            订单编号: {{number}}
            催单时间: {{event_created_at}}
            下单时间: {{placed_at}}
            已过时间: {{passed_time}}
          TMP
        end

        def event_track_from
          event.track_from == 'FromWebpos' ? '收银端' : '微信'
        end

        def event_created_at
          event.created_at_str
        end

        def passed_time
          time_passed = event.created_at_time - order.placed_at
          TimeUtil.label_of_second(time_passed)
        end

        def inline_value_names
          super + [:event_track_from, :event_created_at, :passed_time]
        end
      end
    end
  end
end
