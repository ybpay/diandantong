class CreateSyncL2gRecords < ActiveRecord::Migration
  def change
    unless table_exists? :ddt_cs_sync_l2g_records
      create_table :ddt_cs_sync_l2g_records do |t|
        t.integer :branch_id
        t.integer :seq, limit: 8
        t.integer :local_id
        t.integer :global_id
        t.timestamps
      end

      add_index :ddt_cs_sync_l2g_records, [:branch_id, :seq, :local_id], unique: true, name: 'l2g_index'
    end

    unless table_exists? :ddt_cs_branch_bindings
      create_table :ddt_cs_branch_bindings do |t|
        t.integer :shop_id
        t.integer :branch_id
        t.string :token
        t.timestamps
      end
      add_index :ddt_cs_branch_bindings, :branch_id, unique: true, name: 'cs_branch_binding_index'
    end
  end
end
