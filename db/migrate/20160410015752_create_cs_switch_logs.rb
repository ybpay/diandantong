class CreateCsSwitchLogs < ActiveRecord::Migration
  def up
    create_table :ddt_cs_online_logs do |t|
      t.integer :branch_id
      t.boolean :online
      t.timestamps
    end
    add_index :ddt_cs_online_logs, :branch_id
    add_index :ddt_cs_online_logs, :created_at
  end

  def down
    drop_table :ddt_cs_online_logs if table_exists? :ddt_cs_online_logs
  end
end
