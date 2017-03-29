class CreateTableForCsSyncConfirm < ActiveRecord::Migration
  def up
    add_column :ddt_order_change_logs, :sync_at, :datetime unless column_exists? :ddt_order_change_logs, :sync_at
    add_column :ddt_pay_items, :sync_at, :datetime unless column_exists? :ddt_pay_items, :sync_at

    add_column :ddt_cs_branch_bindings, :last_sync_at, :datetime unless column_exists? :ddt_cs_branch_bindings, :last_sync_at
    add_column :ddt_cs_branch_bindings, :local_ip, :string unless column_exists? :ddt_cs_branch_bindings, :local_ip
    add_column :ddt_cs_branch_bindings, :local_mac, :string unless column_exists? :ddt_cs_branch_bindings, :local_mac
    add_column :ddt_cs_branch_bindings, :version, :string unless column_exists? :ddt_cs_branch_bindings, :version
    add_column :ddt_cs_branch_bindings, :upgraded_at, :datetime unless column_exists? :ddt_cs_branch_bindings, :upgraded_at
  end

  def down
    remove_column :ddt_order_change_logs, :sync_at, :datetime if column_exists? :ddt_order_change_logs, :sync_at
    remove_column :ddt_pay_items, :sync_at, :datetime if column_exists? :ddt_pay_items, :sync_at

    remove_column :ddt_cs_branch_bindings, :last_sync_at if column_exists? :ddt_cs_branch_bindings, :last_sync_at
    remove_column :ddt_cs_branch_bindings, :local_ip if column_exists? :ddt_cs_branch_bindings, :local_ip
    remove_column :ddt_cs_branch_bindings, :local_mac if column_exists? :ddt_cs_branch_bindings, :local_mac
    remove_column :ddt_cs_branch_bindings, :version if column_exists? :ddt_cs_branch_bindings, :version
    remove_column :ddt_cs_branch_bindings, :upgraded_at if column_exists? :ddt_cs_branch_bindings, :upgraded_at
  end
end
