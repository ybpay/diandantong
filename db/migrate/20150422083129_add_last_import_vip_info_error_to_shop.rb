class AddLastImportVipInfoErrorToShop < ActiveRecord::Migration
  def change
    add_column :ddt_shops, :last_import_vip_info_error, :text
  end
end
