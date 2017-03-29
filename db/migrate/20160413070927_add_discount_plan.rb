class AddDiscountPlan < ActiveRecord::Migration
  def change
    create_table :ddt_discount_plans do |t|
      t.references :shop, index: true
      t.references :branch, index: true
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :ddt_discount_plan_items do |t|
      t.references :shop, index: true
      t.references :branch, index: true
      t.references :discount_plan, index: true
      t.string :item_type
      t.decimal :discount, precision: 8, scale: 2, default: 1.0
      t.timestamps
    end

    create_table :ddt_discount_plan_items_variants, id: false, force: true do |t|
      t.integer :discount_plan_item_id
      t.integer :variant_id
    end

    add_index :ddt_discount_plan_items_variants, :discount_plan_item_id, name: "index_dpiv_on_dpi_id", using: :btree
    add_index :ddt_discount_plan_items_variants, :variant_id, name: "index_dpiv_on_v_id", using: :btree

    create_table :ddt_discount_plan_items_categories, id: false, force: true do |t|
      t.integer :discount_plan_item_id
      t.integer :category_id
    end

    add_index :ddt_discount_plan_items_categories, :discount_plan_item_id, name: "index_dpica_on_dpi_id", using: :btree
    add_index :ddt_discount_plan_items_categories, :category_id, name: "index_dpica_on_ca_id", using: :btree

    create_table :ddt_discount_plan_items_combos, id: false, force: true do |t|
      t.integer :discount_plan_item_id
      t.integer :combo_id
    end

    add_index :ddt_discount_plan_items_combos, :discount_plan_item_id, name: "index_dpicombo_on_dpi_id", using: :btree
    add_index :ddt_discount_plan_items_combos, :combo_id, name: "index_dpicombo_on_combo_id", using: :btree
  end
end
