class FixTableWorkflowState < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE ddt_tables AS t JOIN ddt_orders AS o ON t.current_order_id = o.id
      SET t.workflow_state = 'paid'
      WHERE t.workflow_state = 'check_outing' AND o.pay_item_state='paid'
    SQL
  end
end
