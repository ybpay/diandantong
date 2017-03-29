class FixShiftDirtyAmount < ActiveRecord::Migration
  def change
    n = 0
    e = 0
    Ddt::Branch.find_each do |branch|
      branch.shifts.find_each do |shift|
        total_amount = shift.shift_items.sum(:amount).to_f
        actual_amount= shift.shift_items.where(pay_method_is_actual: true).sum(:amount).to_f

        pay_method = branch.shop.pay_methods.find_by(name_sym: :vip_card_pay)
        if pay_method.is_actual?
          extra_amount = shift.shift_items.where(pay_method: pay_method).first.try(:extra_amount)
          actual_amount -= extra_amount if extra_amount.present?
        end

        need_save = false
        if shift.total_amount != total_amount
          shift.total_amount = total_amount
          need_save = true
        end
        if shift.total_actual_amount != actual_amount
          shift.total_actual_amount = actual_amount
          need_save = true
        end

        if need_save
          e += 1
          shift.save!
        end
        n += 1
        puts "#{n}th, shift_id: #{shift.id}" if n == 100
      end
    end
    puts "fix #{e} shifts"
  end
end
