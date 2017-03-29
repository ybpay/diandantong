module Ddt
  module Bill
    module Branch
      class ShiftList < ::Ddt::Bill::Branch::Base
        attr_accessor :search_by, :date, :start_at, :end_at, :time_interval_id
        include Ddt::ShiftBillHelper

        def initialize(branch, params)
          super
          @search_by = params.fetch(:search_by)
          @date = params[:date]
          @start_at = params[:start_at]
          @end_at = params[:end_at]
        end

        def content
          case search_by.to_sym
          when :by_time
            BillTemplate::Shifts::ByTime.new(self).render
          when :by_shift
            BillTemplate::Shifts::ByShift.new(self).render
          end
        end

        def items
          @items ||=
            case search_by.to_sym
            when :by_time
              shift_by_time_range
            when :by_shift
              shift_summary
            end
        end

        def start_time
          case search_by.to_sym
          when :by_time
            "#{@date} #{@start_at}"
          when :by_shift
            @start_time
          end
        end

        def end_time
          case search_by.to_sym
          when :by_time
            "#{@date} #{@end_at}"
          when :by_shift
            @end_time
          end
        end

        def shift_summary
          return @result if @result.present?
          shifts = branch.shifts.closed.where(created_at: start_time..end_time)
          shift_groups = shifts.group_by(&:account_id)
          @result = shift_groups.map do |account_id, shifts|
            if account_id.present?
              account_name = Account.with_deleted.find_by(id: account_id).name
              base_shift_items = ShiftItem.select('pay_method_id, pay_method_name, pay_method_code, sum(amount) as amount, sum(cash_amount) as cash_amount, sum(extra_amount) as extra_amount, sum(actual_amount) as actual_amount, sum(amount - actual_amount) as not_actual_amount').where(shift_id: shifts.map(&:id), item_type: :base).group(:pay_method_id)
              shift_recharge_items = ShiftItem.select('pay_method_id, pay_method_name, pay_method_code, sum(amount) as amount, sum(cash_amount) as cash_amount, sum(extra_amount) as extra_amount, sum(actual_amount) as actual_amount, sum(amount - actual_amount) as not_actual_amount').where(shift_id: shifts.map(&:id), item_type: :recharge).group(:pay_method_id)
              ShiftGroup.new(account_name, base_shift_items, shift_recharge_items, shifts)
            end
          end.compact
          base_shift_items = ShiftItem.select('pay_method_id, pay_method_name, pay_method_code, sum(amount) as amount, sum(cash_amount) as cash_amount, sum(extra_amount) as extra_amount, sum(actual_amount) as actual_amount, sum(amount - actual_amount) as not_actual_amount').where(shift_id: shifts.map(&:id), item_type: :base).group(:pay_method_id)
          shift_recharge_items = ShiftItem.select('pay_method_id, pay_method_name, pay_method_code, sum(amount) as amount, sum(cash_amount) as cash_amount, sum(extra_amount) as extra_amount, sum(actual_amount) as actual_amount, sum(amount - actual_amount) as not_actual_amount').where(shift_id: shifts.map(&:id), item_type: :recharge).group(:pay_method_id)
          @result << ShiftGroup.new("总计", base_shift_items, shift_recharge_items, shifts)
          @result
        end

        def shift_by_time_range
          return @result if @result.present?
          time_range = "#{@start_at} -- #{@end_at}"
          summary = Ddt::BranchSummary.new(@branch, start_at: start_time, end_at: end_time, time_interval_id: @time_interval_id)
          fake_shift = Ddt::Shift.create_fake_shift(summary)
          @result = [ShiftGroup.new(time_range, fake_shift.base_shift_items, fake_shift.recharge_shift_items, [fake_shift])]
        end

        class ShiftGroup
          attr_accessor :name, :base_shift_items, :recharge_shift_items, :shifts
          def initialize(name, base_shift_items, recharge_shift_items, shifts)
            @name = name
            @base_shift_items = base_shift_items
            @recharge_shift_items = recharge_shift_items
            @shifts = shifts
          end

          alias_method :items, :base_shift_items

          [
            :total_customter_count,
            :total_eat_in_hall_order_count,
            :subtract_item_count,
            :total_subtract_item_amount,
            :order_from_wechat_count,
            :order_from_webpos_count,
            :order_from_app_count,
            :recharge_amount,
            :recharge_order_count,
            :recharge_extra_amount,
            :vip_card_pay_amount,
            :exchange_amount,
            :discount_amount,
            :moling_amount,
            :total_amount,
            :unpaid_amount,
            :total_actual_amount,
          ].each do |key|
            define_method key do
              shifts.map(&key).compact.sum
            end
          end

          def per_capita_consumption
            (shifts.map{|s| s.per_capita_consumption * s.total_customter_count }.sum /
            shifts.map{|s| s.total_customter_count }.sum).round(2) rescue 0
          end

          def per_eat_in_hall_order_consumption
            (shifts.map{|s| s.per_eat_in_hall_order_consumption * s.total_eat_in_hall_order_count }.sum /
            shifts.map{|s| s.total_eat_in_hall_order_count }.sum).round(2) rescue 0
          end

          def not_actual_amount
            (total_amount - total_actual_amount).round(2)
          end

          def label_items
            [
              ["消费人数", total_customter_count],
              ["堂点单数", total_eat_in_hall_order_count],
              ["人均", per_capita_consumption],
              ["单均", per_eat_in_hall_order_consumption],
              ["退单数", subtract_item_count],
              ["退单额", total_subtract_item_amount],
              ["来自微信", order_from_wechat_count],
              ["来自收银", order_from_webpos_count],
              ["来自App", order_from_app_count],
              ["充值金额", recharge_amount],
              ["兑换金额", exchange_amount],
              ["未结金额", unpaid_amount],
              ["折扣金额", discount_amount],
              ["抹零调整", moling_amount],
            ]
          end
        end
      end
    end
  end
end
