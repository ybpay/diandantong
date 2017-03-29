class RemoveStateToAdjustment < ActiveRecord::Migration
  def change
    remove_column :ddt_adjustments, :state, :string
  end
end
