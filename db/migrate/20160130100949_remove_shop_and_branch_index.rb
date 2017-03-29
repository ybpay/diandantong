class RemoveShopAndBranchIndex < ActiveRecord::Migration
  def up
    remove_index :ddt_orders, name: "order_shop_branch_index" if index_name_exists?(:ddt_orders, "order_shop_branch_index", false)
    remove_index :ddt_pay_items, name: "index_ddt_pay_items_on_branch_id" if index_name_exists?(:ddt_pay_items, "index_ddt_pay_items_on_branch_id", false)
    add_index :ddt_pay_items, [:branch_id, :paid_at], name: "index_pay_items_on_bid_and_paid_at"
  end

  def down
    remove_index :ddt_pay_items, name: "index_pay_items_on_bid_and_paid_at" if index_name_exists?(:ddt_pay_items, "index_pay_items_on_bid_and_paid_at", false)
  end
end
