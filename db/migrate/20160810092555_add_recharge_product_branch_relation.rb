class AddRechargeProductBranchRelation < ActiveRecord::Migration
  def change
    add_column :ddt_recharge_products, :support_all_branch, :boolean, default: true
    create_table :ddt_recharge_products_branches, id: false do |t|
      t.references :recharge_product
      t.references :branch
    end
    add_index :ddt_recharge_products_branches, :recharge_product_id, name: "index_rpb_on_rp_id"
    add_index :ddt_recharge_products_branches, :branch_id, name: "index_rpb_on_b_id"
    create_table :ddt_recharge_products_branch_groups, id: false do |t|
      t.references :recharge_product
      t.references :branch_group
    end
    add_index :ddt_recharge_products_branch_groups, :recharge_product_id, name: "index_rpbg_on_rp_id"
    add_index :ddt_recharge_products_branch_groups, :branch_group_id, name: "index_rpbg_on_bg_id"
  end
end
