class AddBuiltinToVipInfo < ActiveRecord::Migration
  def change
    add_column :ddt_vip_infos, :builtin, :boolean, :default => false
    vip_info_ids = Ddt::BaseUser.all.map(&:vip_info_id)
    Ddt::VipInfo.where(id: vip_info_ids).update_all(builtin: true)
  end
end
