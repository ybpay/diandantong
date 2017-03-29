class AddTempRechargeProduct < ActiveRecord::Migration
  def change
    create_table "ddt_temp_recharge_products" do |t|
      t.integer  "shop_id"
      t.string   "name"
      t.decimal  "price",                           precision: 8, scale: 2, default: 0.0
      t.decimal  "recharge_amount",                 precision: 8, scale: 2, default: 0.0
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "extra_credits",                                           default: 0
    end
    add_index "ddt_temp_recharge_products", ["shop_id"]
  end
end
