#encoding: utf-8
class FixShiftDataForAntiSettlement < ActiveRecord::Migration
  def change
    shift_ids = Ddt::ShiftItem.where(pay_method_name: '会员卡').where("amount > 0 AND created_at > '2016-02-01 12:33:17'").pluck(:shift_id)
    shift_ids = shift_ids.compact.uniq
    count = 0
    Ddt::Shift.where(id: shift_ids).find_each do |shift|
      count +=1
      shift.update_amount
      puts "FixShiftData #{count}th, shift_id: #{shift.id}" if count % 100==0
    end
  end
end
