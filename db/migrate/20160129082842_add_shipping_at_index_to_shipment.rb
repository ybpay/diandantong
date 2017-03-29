class AddShippingAtIndexToShipment < ActiveRecord::Migration
  def change
    add_index :ddt_shipments, :shipping_at
  end
end
