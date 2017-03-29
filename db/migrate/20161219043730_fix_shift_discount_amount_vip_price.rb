class FixShiftDiscountAmountVipPrice < ActiveRecord::Migration
  def change
    merge_time = Time.parse('2016-11-21 23:08:56')
    Ddt::Shift.closed.where(created_at: merge_time..Time.now).find_each do |shift|
      puts "FIX shift: #{shift.id}"
      summary = Ddt::BranchSummary.new(shift.branch, start_at: shift.created_at, end_at: shift.closed_at)
      shift.discount_amount = summary.discount_amount
      shift.save
    end
  end
end
