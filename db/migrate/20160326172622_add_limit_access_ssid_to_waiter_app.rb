class AddLimitAccessSsidToWaiterApp < ActiveRecord::Migration
  def change
    add_column :ddt_eat_in_hall_settings, :accessable_ssid_for_app, :string
  end
end
