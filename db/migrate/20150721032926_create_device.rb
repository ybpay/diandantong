class CreateDevice < ActiveRecord::Migration
  def change
    create_table :ddt_devices do |t|
      t.references :shop, index: true
      t.references :wechat_account, index: true
      t.references :apply_log
      t.integer :device_id
      t.integer :major
      t.integer :minor
      t.string :uuid
      t.integer :status
      t.integer :poi_id
      t.string :comment
      t.timestamps
    end
    add_index :ddt_devices, :device_id
    add_index :ddt_devices, [:uuid, :major, :minor]
    add_index :ddt_devices, :comment
  end
end
