class AddVariantsPromotionActions < ActiveRecord::Migration
  def change
    create_table "ddt_variants_promotion_actions", id: false do |t|
      t.integer "variant_id"
      t.integer "promotion_action_id"
    end

    add_index "ddt_variants_promotion_actions", ["promotion_action_id"], name: "index_dvpas_on_pid"
    add_index "ddt_variants_promotion_actions", ["variant_id"], name: "index_dvpas_on_vid"

    create_table "ddt_categories_promotion_actions", id: false do |t|
      t.integer "category_id"
      t.integer "promotion_action_id"
    end
    add_index "ddt_categories_promotion_actions", ["promotion_action_id"], name: "index_dcpas_on_pid"
    add_index "ddt_categories_promotion_actions", ["category_id"], name: "index_dcpas_on_cid"
  end
end
