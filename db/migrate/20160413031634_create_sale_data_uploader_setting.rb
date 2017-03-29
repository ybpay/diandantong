class CreateSaleDataUploaderSetting < ActiveRecord::Migration
  def change
    unless table_exists? :ddt_sale_data_uploader_settings
      create_table :ddt_sale_data_uploader_settings do |t|
        t.integer :shop_id
        t.integer :branch_id
        t.boolean :enable, default: false
        t.timestamps
      end
      add_index :ddt_sale_data_uploader_settings, :shop_id, name: "index_sdps_on_shop_id"
      add_index :ddt_sale_data_uploader_settings, :branch_id, name: "index_sdps_on_branch_id"
    end
    Ddt::Branch.all.find_each do |branch|
      branch.create_sale_data_uploader_setting
    end
  end
end
