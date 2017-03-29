class AddColumnsToBranchBindings < ActiveRecord::Migration
  def change
    add_column :ddt_cs_branch_bindings, :remote_ip, :string unless column_exists? :ddt_cs_branch_bindings, :remote_ip

    add_column :ddt_cs_online_logs, :last_sync_at, :datetime unless column_exists? :ddt_cs_online_logs, :last_sync_at
    add_column :ddt_cs_online_logs, :local_ip, :string unless column_exists? :ddt_cs_online_logs, :local_ip
    add_column :ddt_cs_online_logs, :remote_ip, :string unless column_exists? :ddt_cs_online_logs, :remote_ip
    add_column :ddt_cs_online_logs, :local_mac, :string unless column_exists? :ddt_cs_online_logs, :local_mac
    add_column :ddt_cs_online_logs, :version, :string unless column_exists? :ddt_cs_online_logs, :version
    add_column :ddt_cs_online_logs, :upgraded_at, :string unless column_exists? :ddt_cs_online_logs, :upgraded_at
  end
end
