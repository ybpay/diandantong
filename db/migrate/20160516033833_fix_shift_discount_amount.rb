class FixShiftDiscountAmount < ActiveRecord::Migration
  def change
    count = 0
    Ddt::Shift.closed.where(closed_at: Time.new(2016, 5, 5)..Time.new(2016, 5, 9, 23, 59, 59)).each do |shift|
      discount_amount = Ddt::OrderService::Api::Statistic.adjustment_amount(query: {
        branch_id_eq: shift.branch_id,
        created_at_gteq: shift.created_at,
        created_at_lteq: shift.closed_at,
        reason_in: Ddt::OrderService::Adjustment.discount_reasons
      })
      shift.update_columns(discount_amount: discount_amount)
      count +=1
      puts "Fix Shift discount-amount #{count}th, shift_id: #{shift.id}" if count % 100 == 0
    end
    puts "total: #{count}"
  end
end
