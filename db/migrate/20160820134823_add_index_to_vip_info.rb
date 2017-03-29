class AddIndexToVipInfo < ActiveRecord::Migration
  def change
    add_index :ddt_vip_infos, [:shop_id, :updated_at], name: 'vip_info_on_shop_id_updated_at' unless index_exists? :ddt_vip_infos, [:shop_id, :updated_at], :name => "vip_info_on_shop_id_updated_at"
  end
end
