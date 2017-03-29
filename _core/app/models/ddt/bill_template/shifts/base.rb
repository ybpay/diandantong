module Ddt
  module BillTemplate
    module Shifts
      class Base < BillTemplate::Base
        attr_accessor :shift_list, :printer
        delegate :branch, :shop, to: :shift_list
        def initialize(shift_list=nil, printer=nil)
          @shift_list = shift_list
          @printer = printer || Printer::Normal.new(print_spec: "80", use_scene: :webpos)
        end

        def self.virtual_shift_list_of_branch(branch)
          sub_item_1 = OpenStruct.new(
            pay_method_code: "T002",
            pay_method_name: "支付宝",
            amount: 100,
            actual_amount: 100,
            not_actual_amount: 0,
          )

          sub_item_2 = OpenStruct.new(
            pay_method_code: "T003",
            pay_method_name: "会员卡支付",
            amount: 100,
            actual_amount: 50,
            not_actual_amount: 50,
          )

          sub_item_3 = OpenStruct.new(
            pay_method_code: "T004",
            pay_method_name: "美团券",
            amount: 100,
            actual_amount: 80,
            not_actual_amount: 20,
          )

          name = self.name.demodulize == "ByTime" ? "09:00  --  19:00" : "收银员A"
          item = OpenStruct.new(
            :name => name,
            :total_customter_count => 1,
            :total_eat_in_hall_order_count => 1,
            :per_capita_consumption => 1.00,
            :per_eat_in_hall_order_consumption => 1.00,
            :subtract_item_count => 1,
            :total_subtract_item_amount => 1.00,
            :order_from_wechat_count => 1,
            :order_from_webpos_count => 1,
            :order_from_app_count => 1,
            :recharge_amount => 1.00,
            :exchange_amount => 1.00,
            :discount_amount => 1.00,
            :moling_amount => 1.00,
            :total_amount => 1.00,
            :not_actual_amount => 1.00,
            :total_actual_amount => 1.00,
            :unpaid_amount => 20,
            :items => [sub_item_1, sub_item_2, sub_item_3],
            :shift_recharge_items => [sub_item_1, sub_item_3],
            :recharge_order_count => 1,
            :recharge_extra_amount => 1.00,
            :vip_card_pay_amount => 1.00
          )

          shift_list = OpenStruct.new({
            branch: branch,
            start_time: Date.today.beginning_of_day,
            end_time: Time.now,
            operator_name: "操作者",
            items: [item]
          })
        end

        def self.preview(branch)
          printer = Printer::Normal.new(print_spec: "80", use_scene: :webpos)
          shift_list = virtual_shift_list_of_branch(branch)
          self.new(shift_list, printer).render
        end

        private
        def replace_if_tag(text)
          replaced_text = text
          if_tags = TagHelper.scan_tag(text, "if")
          if_tags.each do |tag|
            replaced_text = replaced_text.sub(tag.body, tag.render(shift_list))
          end
          replaced_text
        end

        def branch_name
          branch.name
        end

        def time_now
          Time.now.strftime("%F %T")
        end

        delegate :start_time, :end_time, :operator_name,
          to: :shift_list

        def inline_value_names
          base_inline_value_names +
          [
            :branch_name, :start_time, :end_time, :operator_name, :time_now
          ]
        end
      end
    end
  end
end
