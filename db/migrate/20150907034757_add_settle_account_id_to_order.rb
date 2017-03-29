class AddSettleAccountIdToOrder < ActiveRecord::Migration
  def change
    add_column :ddt_orders, :settle_account_id, :integer
    add_index :ddt_orders, :settle_account_id
  end
end
