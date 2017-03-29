class AddIsOemToPushChannel < ActiveRecord::Migration
  def change
    add_column :ddt_push_channels, :is_oem, :boolean, default: false
  end
end
