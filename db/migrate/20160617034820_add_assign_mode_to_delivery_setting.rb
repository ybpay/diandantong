class AddAssignModeToDeliverySetting < ActiveRecord::Migration
  def change
    add_column :ddt_delivery_settings, :assign_mode, :string, default: :passive
  end
end
