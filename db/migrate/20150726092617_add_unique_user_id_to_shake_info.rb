class AddUniqueUserIdToShakeInfo < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_shake_infos, :unique_user_id
      add_column :ddt_shake_infos, :unique_user_id, :integer
      add_column :ddt_shake_infos, :user_id, :integer
      add_index :ddt_shake_infos, :unique_user_id
      add_index :ddt_shake_infos, :user_id
    end
  end
end
