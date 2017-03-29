class RemoveAdjustmentTotalToShipment < ActiveRecord::Migration
  def change
    remove_column :ddt_shipments, :adjustment_total, :decimal, precision: 8, scale: 2, default: 0.0
  end
end
