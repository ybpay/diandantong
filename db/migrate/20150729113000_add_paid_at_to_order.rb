class AddPaidAtToOrder < ActiveRecord::Migration
  def up
    add_column :ddt_orders, :paid_at, :datetime
    add_index :ddt_orders, :paid_at
    execute "UPDATE ddt_orders o SET o.paid_at = o.completed_at WHERE o.placed_at IS NOT null AND o.pay_item_state = 'paid' AND o.completed_at IS NOT null;"
    execute "UPDATE ddt_orders o SET o.paid_at = o.placed_at WHERE o.placed_at IS NOT null AND o.pay_item_state = 'paid' AND o.completed_at IS null;"
  end

  def down
    remove_index :ddt_orders, :paid_at
    remove_column :ddt_orders, :paid_at, :datetime
  end
end
