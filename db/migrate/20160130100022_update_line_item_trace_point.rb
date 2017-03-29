class UpdateLineItemTracePoint < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE ddt_line_items line_item
      LEFT JOIN ddt_line_item_trace_points litp ON line_item.id = litp.line_item_id
      LEFT JOIN ddt_order_change_logs log ON log.id = litp.order_change_log_id
      SET
        line_item.order_change_log_id = log.id
      where log.type in ("Ddt::OrderChangeLog::OrderPlace", "Ddt::OrderChangeLog::AppendItemable");
    SQL
  end

  def down
  end
end
