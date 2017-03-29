class AddDeviceIdToShakeInfo < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_shake_infos, :device_id
      add_column :ddt_shake_infos, :device_id, :integer
      add_index :ddt_shake_infos, :device_id
    end
  end
end
