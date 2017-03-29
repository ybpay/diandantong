class AddApplyingRefundToBaseCoupon < ActiveRecord::Migration
  def change
    add_column :ddt_base_coupons, :applying_refund, :boolean, default: false
  end
end
