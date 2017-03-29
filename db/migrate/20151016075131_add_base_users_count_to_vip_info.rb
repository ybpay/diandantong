class AddBaseUsersCountToVipInfo < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_vip_infos, :base_users_count
      add_column :ddt_vip_infos, :base_users_count, :integer, default: 0
    end
  end
end
