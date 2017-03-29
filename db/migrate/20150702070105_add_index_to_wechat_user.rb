class AddIndexToWechatUser < ActiveRecord::Migration
  def change
  	change_column :ddt_wechat_users, :user_open_id, :string, limit: 191
  	unless index_exists? :ddt_wechat_users, :user_open_id
    	add_index :ddt_wechat_users, :user_open_id
    end
  	change_column :ddt_wechat_users, :gonghao_open_id, :string, limit: 191
  	unless index_exists? :ddt_wechat_users, :gonghao_open_id
    	add_index :ddt_wechat_users, :gonghao_open_id
    end
  end
end
