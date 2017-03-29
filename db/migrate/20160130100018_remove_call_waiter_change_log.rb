class RemoveCallWaiterChangeLog < ActiveRecord::Migration
  def up
    execute <<-SQL
      delete from ddt_order_change_logs where type = "Ddt::OrderChangeLog::CallWaiter";
    SQL
  end

  def down
  end
end
