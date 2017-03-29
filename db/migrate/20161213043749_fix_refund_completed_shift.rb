class FixRefundCompletedShift < ActiveRecord::Migration
  def change
    Octopus.using(:master) do
      @fixed = []
      r = execute <<-SQL
      SELECT branch_id, DATE_FORMAT(updated_at, '%Y-%m-%d') as day
      FROM ddt_recharge_refunds
      WHERE
        state = 'completed'
        AND updated_at < '2016-12-07 23:59:59'
        AND DATE_FORMAT(created_at, '%Y-%m-%d') != DATE_FORMAT(updated_at, '%Y-%m-%d')
      SQL
      r = r.to_a
      r.each do |row|
        next if @fixed.include?(row)
        # row[0] branch_id
        # row[1] day
        puts "Fix: #{row[0]} --> #{row[1]}"
        d = Time.parse(row[1])
        Ddt::Shift.closed.where(branch_id: row[0], created_at: d.beginning_of_day..d.end_of_day).each do |shift|
          shift.update_amount
        end
        @fixed << row
      end
    end
  end

end
