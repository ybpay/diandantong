class AddEnableAutoShipToDeliverySetting < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_delivery_settings, :enable_auto_ship
      add_column :ddt_delivery_settings, :enable_auto_ship, :boolean, default: false
    end
  end
end
