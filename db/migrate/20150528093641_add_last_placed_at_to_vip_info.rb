class AddLastPlacedAtToVipInfo < ActiveRecord::Migration
  def change
    add_column :ddt_vip_infos, :last_placed_at, :datetime
    add_index :ddt_vip_infos, :last_placed_at
  end
end
