class AddLastCallWaiterAtToOrderExt < ActiveRecord::Migration
  def change
    add_column :ddt_order_exts, :last_call_waiter_at, :datetime
  end
end
