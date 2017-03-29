class FixShifts < ActiveRecord::Migration
  def change
    count = 0
    Octopus.using(:master) do
      Ddt::Shift.closed.where("created_at >= '2016-09-09 00:00:00'").find_each do |shift|
        shift.update_amount
        count += 1
        puts "FixShiftData #{count}th, shift_id: #{shift.id}" if count % 100 == 0
      end
    end
  end
end
