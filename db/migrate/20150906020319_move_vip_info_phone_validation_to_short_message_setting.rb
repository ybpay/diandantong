class MoveVipInfoPhoneValidationToShortMessageSetting < ActiveRecord::Migration
  def change
    remove_column :ddt_shops, :enable_vip_info_phone_validation, :boolean, default: false
    add_column :ddt_short_message_settings, :enable_vip_info_phone_validation, :boolean, default: false
  end
end
