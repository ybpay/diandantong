class FixRefundCompletedShift < ActiveRecord::Migration
  def change
    @fixed = []
    r = execute <<-SQL
    SELECT branch_id, TO_CHAR(updated_at, 'YYYY-MM-DD') as day
    FROM ddt_recharge_refunds
    WHERE
      state = 'completed'
      AND updated_at < '2016-12-07 23:59:59'
      AND TO_CHAR(created_at, 'YYYY-MM-DD') != TO_CHAR(updated_at, 'YYYY-MM-DD')
    SQL
    r = r.to_a
    r.each do |row|
      next if @fixed.include?(row)
      puts "Fix: #{row[0]} --> #{row[1]}"
      d = Time.parse(row[1])
      Ddt::Shift.closed.where(branch_id: row[0], created_at: d.beginning_of_day..d.end_of_day).each do |shift|
        shift.update_amount
      end
      @fixed << row
    end
  end

end
