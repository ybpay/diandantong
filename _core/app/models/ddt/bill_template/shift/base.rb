module Ddt
  module BillTemplate
    module Shift
      class Base < BillTemplate::Base
        attr_accessor :shift, :printer
        delegate :branch, :shop, to: :shift
        def initialize(shift=nil, printer=nil)
          @shift = shift
          @printer = printer || Printer::Normal.new(print_spec: "58", use_scene: :webpos)
        end

        def self.virtual_shift_of_branch(branch)
          item_1 = OpenStruct.new(
            pay_method_code: "T001",
            pay_method_name: "现金",
            amount: 100,
            actual_amount: 100,
            not_actual_amount: 0,
          )
          item_2 = OpenStruct.new(
            pay_method_code: "T002",
            pay_method_name: "支付宝",
            amount: 100,
            actual_amount: 100,
            not_actual_amount: 0,
          )
          item_3 = OpenStruct.new(
            pay_method_code: "T003",
            pay_method_name: "会员支付",
            amount: 100,
            actual_amount: 80,
            not_actual_amount: 20,
          )
          shift = OpenStruct.new({
            branch: branch,
            shop: branch.shop,
            account: OpenStruct.new({name: "小王"}),
            created_at: 2.minutes.ago,
            shift_closed_at: 1.minute.ago,
            closed_at: 1.minute.ago,
            total_customter_count: 10,
            order_from_wechat_count: 10,
            order_from_webpos_count: 10,
            order_from_app_count: 10,
            total_eat_in_hall_order_count: 10,
            per_capita_consumption: 10.0,
            per_eat_in_hall_order_consumption: 10.0,
            subtract_item_count: 10,
            total_subtract_item_amount: 10.0,
            total_amount: 10.0,
            total_actual_amount: 10.0,
            recharge_amount: 10.0,
            recharge_extra_amount: 10.0,
            vip_card_pay_amount: 10.0,
            recharge_order_count: 10,
            pre_cash_amount: 10.0,
            discount_amount: 15.0,
            moling_amount: -2.3,
            unpaid_amount: 20,
            base_shift_items: [item_1, item_2, item_3],
            recharge_shift_items: [item_1, item_2]
          })
        end

        def self.preview(branch)
          printer = Printer::Normal.new(print_spec: "58", use_scene: :webpos)
          shift = virtual_shift_of_branch(branch)
          self.new(shift, printer).render
        end

        private
        def replace_if_tag(text)
          replaced_text = text
          if_tags = TagHelper.scan_tag(text, "if")
          if_tags.each do |tag|
            replaced_text = replaced_text.sub(tag.body, tag.render(shift))
          end
          replaced_text
        end

        def branch_name
          branch.name
        end

        def shift_account_name
          shift.account.try(:name)
        end

        def shift_created_at
          shift.created_at.strftime("%F %T")
        end

        def shift_closed_at
          shift.closed_at.try(:strftime, "%F %T")
        end
        alias_method :closed_at, :shift_closed_at

        def time_now
          Time.now.strftime("%F %T")
        end

        def shift_items_title
          case bill_width
          when 32
            "科目代码 支付方式 支付金额  次数"
          when 40
            "科目代码 支付方式 支付金额  次数"
          end
        end

        delegate :total_customter_count,
                  :order_from_wechat_count,
                  :order_from_webpos_count,
                  :order_from_app_count,
                  :total_eat_in_hall_order_count,
                  :per_capita_consumption,
                  :per_eat_in_hall_order_consumption,
                  :subtract_item_count,
                  :total_subtract_item_amount,
                  :total_amount,
                  :total_actual_amount,
                  :recharge_amount,
                  :recharge_extra_amount,
                  :vip_card_pay_amount,
                  :recharge_order_count,
                  :pre_cash_amount,
                  :discount_amount,
                  :moling_amount,
                  :unpaid_amount,
                  to: :shift

        def not_actual_amount
          shift.total_amount - shift.total_actual_amount
        end

        def inline_value_names
          base_inline_value_names +
          [
            :branch_name, :shift_account_name, :shift_created_at, :shift_closed_at, :time_now, :shift_items_title,
            :total_customter_count, :order_from_wechat_count, :order_from_webpos_count, :order_from_app_count, :total_eat_in_hall_order_count, :per_capita_consumption, :per_eat_in_hall_order_consumption, :subtract_item_count, :total_subtract_item_amount, :total_amount, :total_actual_amount,
            :recharge_amount, :recharge_extra_amount, :vip_card_pay_amount, :recharge_order_count, :pre_cash_amount,
            :not_actual_amount, :discount_amount, :moling_amount, :unpaid_amount
          ]
        end
      end
    end
  end
end
