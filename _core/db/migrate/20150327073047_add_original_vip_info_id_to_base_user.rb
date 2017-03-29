class AddOriginalVipInfoIdToBaseUser < ActiveRecord::Migration
  def change
    add_column :ddt_base_users, :original_vip_info_id, :integer
  end
end
