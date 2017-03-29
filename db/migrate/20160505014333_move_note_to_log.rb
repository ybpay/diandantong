class MoveNoteToLog < ActiveRecord::Migration
  def up
    execute <<-SQL
      update ddt_order_change_logs l
      join ddt_orders o on l.order_id = o.id
      set l.description = o.note
      where l.type = "Ddt::OrderChangeLog::OrderPlace" and length(o.note) < 191;
    SQL
    # remove_column :ddt_orders, :note, :text
  end

  def down
    # add_column :ddt_orders, :note, :text
  end
end
