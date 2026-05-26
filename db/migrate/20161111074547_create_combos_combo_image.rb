class CreateCombosComboImage < ActiveRecord::Migration
  def change
    create_table "ddt_combos_combo_images" do |t|
      t.integer "combo_id"
      t.integer "combo_image_id"
      t.integer "position"
    end

    add_index "ddt_combos_combo_images", ["combo_id"], name: "index_ddt_combos_combo_images_on_combo_id"
    add_index "ddt_combos_combo_images", ["combo_image_id"], name: "index_ddt_combos_combo_images_on_combo_image_id"

  end
end
