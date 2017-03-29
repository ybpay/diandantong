class CreateEssentialProducts < ActiveRecord::Migration
  def change
    create_table :ddt_essential_products do |t|
      t.integer :shop_id
      t.integer :branch_id
      t.integer :variant_id
      t.integer :quantity
      t.boolean :per_guest
      t.timestamps
    end
    add_index :ddt_essential_products, :shop_id
    add_index :ddt_essential_products, :branch_id
    add_index :ddt_essential_products, :variant_id
  end
end
