class CreateVipInfoSettings < ActiveRecord::Migration
  def change
    unless table_exists? :ddt_vip_info_settings
      create_table :ddt_vip_info_settings do |t|
        t.references :shop, index: true
        t.text :data
        t.timestamps
      end
    end
    Ddt::Shop.all.find_each do |shop|
      shop.create_vip_info_setting
    end
  end
end
