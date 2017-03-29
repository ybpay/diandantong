class AddValidationCodeToVipInfo < ActiveRecord::Migration
  def change
    add_column :ddt_vip_infos, :validation_phone, :string
    add_column :ddt_shops, :enable_vip_info_phone_validation, :boolean, default: false
  end
end
