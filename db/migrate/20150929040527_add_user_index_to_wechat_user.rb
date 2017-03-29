class AddUserIndexToWechatUser < ActiveRecord::Migration
  def change
  	remove_index :ddt_wechat_users, :user_id
  	add_index :ddt_wechat_users, [:user_id, :gonghao_open_id, :user_open_id],:name => :user_gonghao_open_index
  end
end
