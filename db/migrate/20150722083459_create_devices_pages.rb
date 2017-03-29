class CreateDevicesPages < ActiveRecord::Migration
  def change
    create_table :ddt_devices_pages do |t|
      t.integer :device_id
      t.integer :page_id
    end
    add_index :ddt_devices_pages, [:device_id, :page_id]
  end
end
