class AddCostToDeliveryTime < ActiveRecord::Migration
  def change
    add_column :ddt_delivery_times, :cost, :decimal, precision: 8, scale: 2, default: 0.0
  end
end
