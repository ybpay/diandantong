class UpdateCallSettingAmount < ActiveRecord::Migration
  def change
  	Ddt::CallSetting.update_all("amount = 0.5")
  end
end
