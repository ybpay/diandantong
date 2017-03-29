module Ddt
  module ShiftBillHelper
    extend ActiveSupport::Concern

    def shift_items_title
      "#{'科目代码'.fixed_width(8)} #{'支付方式'.fixed_width(16)} #{'支付金额'.fixed_width(8)}"
    end

    def format_shift_items(items)
      text = []
      items.each do |item|
        if item.amount > 0
          text << "#{item.pay_method_code.fixed_width(8)} #{item.pay_method_name.fixed_width(16)} #{item.amount.fixed_width(8)}"
          if item.cash_amount.present?
            text << "#{"".fixed_width(8)} #{"#{item.pay_method_name}(实收)".fixed_width(16)} #{item.cash_amount.fixed_width(8)}"
            text << "#{"".fixed_width(8)} #{"#{item.pay_method_name}(附属)".fixed_width(16)} #{item.extra_amount.fixed_width(8)}"
          end
        end
      end
      text
    end

    # items: [[label, value]...]
    def format_label_items(items)
      text = []
      while items.size > 0
        group = items.shift(2)
        mem1 = group[0]
        mem2 = group[1]
        line  = "#{mem1[0].fixed_width(10, float: :right)}:#{mem1[1].fixed_width(8)}"
        unless mem2.nil?
          line << "   "
          line << "#{mem2[0].fixed_width(10, float: :right)}:#{mem2[1].fixed_width(8)}"
        end
        text << line
      end
      text
    end

  end
end
