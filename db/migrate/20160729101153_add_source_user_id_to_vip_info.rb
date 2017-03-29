class AddSourceUserIdToVipInfo < ActiveRecord::Migration
  def change
    add_column :ddt_vip_infos, :source_user_id, :integer
    add_index :ddt_vip_infos, :source_user_id
  end
end
