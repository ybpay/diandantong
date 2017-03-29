class CreateShakeInfo < ActiveRecord::Migration
  def change
    create_table :ddt_shake_infos do |t|
      t.string :user_open_id
      t.integer :page_id
      t.integer :poi_id
      t.boolean :is_from_notify
      t.string :wechat_account_wxhao
      t.datetime :shake_time
      t.references :wechat_account, index: true
      t.references :shop, index: true
      t.timestamps
    end
    add_index :ddt_shake_infos, :user_open_id
    add_index :ddt_shake_infos, :page_id
  end
end
