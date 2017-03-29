class AddDisableNoticeToWechatModule < ActiveRecord::Migration
  def up
  	Ddt::WechatModule.update_all("enable = true")
  	unless column_exists? :ddt_wechat_modules, :disable_notice
    	add_column :ddt_wechat_modules, :disable_notice, :string, limit: 255
    end
  end

  def down
  	if column_exists? :ddt_wechat_modules, :disable_notice
  		remove_column :ddt_wechat_modules, :disable_notice
  	end
  end
end
