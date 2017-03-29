class RemoveWechatUserIndex < ActiveRecord::Migration
  def change
  	remove_index :ddt_wechat_users, :name => "user_gonghao_open_index"
  	add_index :ddt_wechat_users, :user_id
  	add_index :ddt_wechat_users, :gonghao_open_id, :name => "gonghao_open_id_index"
  end
end
