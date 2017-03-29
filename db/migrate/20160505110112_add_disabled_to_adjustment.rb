class AddDisabledToAdjustment < ActiveRecord::Migration
  def change
    add_column :ddt_adjustments, :disabled, :boolean, default: false
  end
end
