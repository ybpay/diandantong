class AlterColumnCsOnlineLogUpgradedAt < ActiveRecord::Migration
  def change
    change_column :ddt_cs_online_logs, :upgraded_at, :datetime
  end
end
