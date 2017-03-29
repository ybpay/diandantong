class AddServerAuthFileToDdtWechatAccounts < ActiveRecord::Migration
  def change
    add_column :ddt_wechat_accounts, :server_auth_file, :string
    add_index :ddt_wechat_accounts, :server_auth_file
  end
end
