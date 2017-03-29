class RemoveEligibleToAdjustment < ActiveRecord::Migration
  def change
    remove_column :ddt_adjustments, :eligible, :boolean
  end
end
