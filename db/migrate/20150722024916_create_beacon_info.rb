class CreateBeaconInfo < ActiveRecord::Migration
  def change
    create_table :ddt_beacon_infos do |t|
      t.integer :major
      t.integer :minor
      t.string :uuid
      t.decimal :distance, precision:8, scale: 2
      t.boolean :is_chosen
      t.integer :device_id
      t.string :comment
      t.references :shake_info, index: true
      t.references :wechat_account, index: true
      t.references :shop, index: true
      t.timestamps
    end
    add_index :ddt_beacon_infos, [:device_id]
  end
end
