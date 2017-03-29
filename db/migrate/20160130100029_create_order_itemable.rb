class CreateOrderItemable < ActiveRecord::Migration
  def change
    unless table_exists? :ddt_order_itemables
      create_table :ddt_order_itemables do |t|
        t.references :shop
        t.references :branch
        t.integer :base_user_id
        t.string :itemable_type
        t.integer :itemable_id
        t.integer :quantity
        t.string :note
        t.timestamps
      end
      add_index :ddt_order_itemables, :base_user_id
      add_index :ddt_order_itemables, [:itemable_type, :itemable_id], name: "index_order_itemables_on_itemable"
    end
  end
end
