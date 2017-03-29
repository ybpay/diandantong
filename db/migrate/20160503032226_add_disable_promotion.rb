class AddDisablePromotion < ActiveRecord::Migration
  def change
    create_table :ddt_orders_disabled_promotions, id: false do |t|
      t.integer :order_id
      t.integer :promotion_id
    end

    add_index :ddt_orders_disabled_promotions, [:order_id, :promotion_id], name: "index_odp_on_oid_and_pid"
  end
end
