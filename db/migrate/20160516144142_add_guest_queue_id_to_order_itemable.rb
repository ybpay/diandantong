class AddGuestQueueIdToOrderItemable < ActiveRecord::Migration
  def change
    add_column :ddt_order_itemables, :guest_queue_id, :integer
    add_index :ddt_order_itemables, :guest_queue_id, name: "order_itemables_guest_queue_id"
  end
end
