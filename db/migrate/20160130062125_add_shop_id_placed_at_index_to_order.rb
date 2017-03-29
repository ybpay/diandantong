class AddShopIdPlacedAtIndexToOrder < ActiveRecord::Migration
  def up
    remove_index "ddt_orders", name: "index_ddt_orders_on_state"        if index_name_exists?("ddt_orders", "index_ddt_orders_on_state", false)
    remove_index "ddt_orders", name: "index_ddt_orders_on_track_from"   if index_name_exists?("ddt_orders", "index_ddt_orders_on_track_from", false)
    remove_index "ddt_orders", name: "index_ddt_orders_on_type_and_id"  if index_name_exists?("ddt_orders", "index_ddt_orders_on_type_and_id", false)
    remove_index "ddt_orders", name: "index_ddt_orders_on_completed_at" if index_name_exists?("ddt_orders", "index_ddt_orders_on_completed_at", false)
    remove_index "ddt_orders", name: "index_ddt_orders_on_created_at"   if index_name_exists?("ddt_orders", "index_ddt_orders_on_created_at", false)
    remove_index "ddt_orders", name: "index_ddt_orders_on_paid_at"      if index_name_exists?("ddt_orders", "index_ddt_orders_on_paid_at", false)
    remove_index "ddt_orders", name: "index_ddt_orders_on_placed_at"    if index_name_exists?("ddt_orders", "index_ddt_orders_on_placed_at", false)
    remove_index "ddt_orders", name: "index_ddt_orders_on_updated_at"   if index_name_exists?("ddt_orders", "index_ddt_orders_on_updated_at", false)
    remove_index "ddt_orders", name: "index_orders_on_bid_placed_at"           if index_name_exists?("ddt_orders", "index_orders_on_bid_placed_at", false)
    remove_index "ddt_orders", name: "index_orders_on_bid_type_placed_at"      if index_name_exists?("ddt_orders", "index_orders_on_bid_type_placed_at", false)
    remove_index "ddt_orders", name: "order_shop_state_index"                  if index_name_exists?("ddt_orders", "order_shop_state_index", false)

    remove_index "ddt_orders", name: "index_ddt_orders_on_branch_id_and_state_and_placed_at"   if index_name_exists?("ddt_orders", "index_ddt_orders_on_branch_id_and_state_and_placed_at", false)
    remove_index "ddt_orders", name: "index_ddt_orders_on_branch_id_and_type_and_placed_at"   if index_name_exists?("ddt_orders", "index_ddt_orders_on_branch_id_and_type_and_placed_at", false)

    add_index "ddt_orders", [:branch_id, :placed_at],    name: "index_orders_on_bid_and_placed_at"
    add_index "ddt_orders", [:branch_id, :completed_at], name: "index_orders_on_bid_and_completed_at"
    add_index "ddt_orders", [:branch_id, :paid_at],      name: "index_orders_on_bid_and_paid_at"

    add_index "ddt_orders", [:shop_id, :completed_at],   name: "index_orders_on_sid_and_completed_at"
    add_index "ddt_orders", [:shop_id, :paid_at],        name: "index_orders_on_sid_and_paid_at"
    add_index "ddt_orders", [:shop_id, :placed_at],      name: "index_orders_on_sid_and_placed_at"

    add_index "ddt_orders", [:completed_at, :shop_id],   name: "index_orders_on_completed_at_and_sid"
    add_index "ddt_orders", [:paid_at, :shop_id],        name: "index_orders_on_paid_at_and_sid"
    add_index "ddt_orders", [:placed_at, :shop_id],      name: "index_orders_on_placed_at_and_sid"

    remove_index "ddt_line_items", name: "index_ddt_line_items_on_branch_id" if index_exists?("ddt_line_items", :branch_id, name: "index_ddt_line_items_on_branch_id")
    add_index "ddt_line_items", [:branch_id, :created_at], name: "index_line_items_on_bid_and_created_at"

  end

  def down
    remove_index "ddt_orders", name: "index_orders_on_bid_and_placed_at"    if index_name_exists?("ddt_orders", "index_orders_on_bid_and_placed_at", false)
    remove_index "ddt_orders", name: "index_orders_on_bid_and_completed_at" if index_name_exists?("ddt_orders", "index_orders_on_bid_and_completed_at", false)
    remove_index "ddt_orders", name: "index_orders_on_bid_and_paid_at"      if index_name_exists?("ddt_orders", "index_orders_on_bid_and_paid_at", false)
    remove_index "ddt_orders", name: "index_orders_on_sid_and_completed_at" if index_name_exists?("ddt_orders", "index_orders_on_sid_and_completed_at", false)
    remove_index "ddt_orders", name: "index_orders_on_sid_and_paid_at"      if index_name_exists?("ddt_orders", "index_orders_on_sid_and_paid_at", false)
    remove_index "ddt_orders", name: "index_orders_on_sid_and_placed_at"    if index_name_exists?("ddt_orders", "index_orders_on_sid_and_placed_at", false)
    remove_index "ddt_orders", name: "index_orders_on_completed_at_and_sid" if index_name_exists?("ddt_orders", "index_orders_on_completed_at_and_sid", false)
    remove_index "ddt_orders", name: "index_orders_on_paid_at_and_sid"      if index_name_exists?("ddt_orders", "index_orders_on_paid_at_and_sid", false)
    remove_index "ddt_orders", name: "index_orders_on_placed_at_and_sid"    if index_name_exists?("ddt_orders", "index_orders_on_placed_at_and_sid", false)

    remove_index "ddt_line_items", name: "index_line_items_on_bid_and_created_at" if index_name_exists?("ddt_line_items", "index_line_items_on_bid_and_created_at", false)
  end
end
