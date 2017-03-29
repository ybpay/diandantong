module Ddt
  module Bill
    module Shift
      class Base
        include Ddt::ShiftBillHelper
        attr_accessor :shift
        def initialize(shift)
          @shift = shift
        end

        def content
          end_time = shift.closed_at || Time.now
          text = []
          text << "交班记录"
          text << "  值班人:  #{shift.account.try(:name)}"
          text << "值班开始时间:  #{shift.created_at.strftime("%F %T")}"
          if shift.closed_at.present?
            text << "值班结束时间:  #{end_time.strftime("%F %T")}"
          else
            text << "          至:  #{end_time.strftime("%F %T")}"
          end
          text << "-" * 32
          text << "人数: #{shift.total_customter_count}"
          text << "来自微信: #{shift.order_from_wechat_count}"
          text << "来自收银端: #{shift.order_from_webpos_count}"
          text << "来自App: #{shift.order_from_app_count}"
          text << "堂点单数: #{shift.total_eat_in_hall_order_count}"
          text << "人均消费: #{shift.per_capita_consumption}"
          text << "单均消费: #{shift.per_eat_in_hall_order_consumption}"
          text << "退菜数量: #{shift.subtract_item_count}"
          text << "退菜金额: #{shift.total_subtract_item_amount}"
          text << "折扣金额: #{shift.discount_amount}"
          text << "抹零调整: #{shift.moling_amount}"
          text << "-" * 32
          text << self.shift_items_title
          text << "-" * 32
          text.concat shift_items_text
          text << "-" * 32
          text << "      合计金额： #{shift.total_amount}"
          text << "      非实收金额： #{shift.total_amount - shift.total_actual_amount}"
          text << "      未结算金额：#{shift.unpaid_amount}"
          text << "      营业额： #{shift.total_actual_amount}"
          # text << "当班前未确认订单:  #{shift.pending_orders_before}"
          # text << "当班后未确认订单:  #{shift.pending_orders_after}"
          # text << "当班前已确认订单:  #{shift.confirmed_orders_before}"
          # text << "当班后已确认订单:  #{shift.confirmed_orders_after}"
          # text << " 当班时完成订单:  #{shift.completed_orders_after - shift.completed_orders_before}"
          text << "会员卡充值金额:  #{shift.recharge_amount}" if shift.recharge_amount > 0
          text << "      放入现金:  #{shift.pre_cash_amount}" if shift.pre_cash_amount.present?
          text << "\n"
          text.join("\n")
        end

        def shift_items_text
          format_shift_items(shift.base_shift_items)
        end

      end
    end
  end
end
