class AddCountToDevices < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_devices, :count
      add_column :ddt_devices, :count, :integer, default: 0
      add_column :ddt_pages, :count, :integer, default: 0
    end
  end
end
