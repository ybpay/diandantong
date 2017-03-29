class AddLastActiveTimeToDevices < ActiveRecord::Migration
  def change
    add_column :ddt_devices, :last_active_time, :datetime
  end
end
