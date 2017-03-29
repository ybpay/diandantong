class RemoveWechatIntroduceUrlFromWechatAccounts < ActiveRecord::Migration
  def change
    if column_exists? :ddt_wechat_accounts, :wechat_introduce_url
      remove_column :ddt_wechat_accounts, :wechat_introduce_url
    end
  end
end
