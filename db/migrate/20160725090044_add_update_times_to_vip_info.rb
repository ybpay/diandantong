class AddUpdateTimesToVipInfo < ActiveRecord::Migration
  def change
    add_column :ddt_vip_infos, :update_times, :integer, default: 0
  end
end
