class FixCouponData < ActiveRecord::Migration
  def change
    Ddt::AbstractCouponVersion.where(support_refund_any_time: true).update_all(support_refund: true)
    Ddt::AbstractCouponVersion.where(support_refund_after_expired: true).update_all(support_refund: true)

    remove_column :ddt_abstract_coupon_versions, :support_refund_any_time
    remove_column :ddt_abstract_coupon_versions, :support_refund_after_expired
  end
end
