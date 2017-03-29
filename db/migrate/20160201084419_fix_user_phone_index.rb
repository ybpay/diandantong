class FixUserPhoneIndex < ActiveRecord::Migration
  def up
    remove_index :ddt_base_users, name: "index_ddt_base_users_on_phone" if index_name_exists?(:ddt_base_users, "index_ddt_base_users_on_phone", false)
    add_index :ddt_base_users, [:shop_id, :phone], name: "index_base_users_on_sid_and_phone"
  end

  def down
    remove_index :ddt_base_users, name: "index_base_users_on_sid_and_phone" if index_name_exists?(:ddt_base_users, "index_base_users_on_sid_and_phone", false)
  end
end
