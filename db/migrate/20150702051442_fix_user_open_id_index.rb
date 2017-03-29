class FixUserOpenIdIndex < ActiveRecord::Migration
  def change
  	change_column :ddt_wechat_subscribe_relationships, :user_open_id, :string, limit: 191
  	add_index :ddt_wechat_subscribe_relationships, :user_open_id
  end
end
