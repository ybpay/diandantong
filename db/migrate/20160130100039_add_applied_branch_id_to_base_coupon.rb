class AddAppliedBranchIdToBaseCoupon < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_base_coupons, :applied_in_branch_id
      add_column :ddt_base_coupons, :applied_in_branch_id, :integer
    end
    execute <<-SQL
      UPDATE ddt_base_coupons as coupon 
      LEFT JOIN ddt_orders as o ON coupon.applied_to_order_id = o.id
      SET coupon.applied_in_branch_id=o.branch_id
      WHERE o.id IS NOT NULL and o.branch_id IS NOT NULL
    SQL
  end
end
