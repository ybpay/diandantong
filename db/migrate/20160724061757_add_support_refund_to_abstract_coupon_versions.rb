class AddSupportRefundToAbstractCouponVersions < ActiveRecord::Migration
  def change
    add_column :ddt_abstract_coupon_versions, :support_refund, :boolean, default: false
    add_column :ddt_abstract_coupon_versions, :refundable_days_after_send, :integer, default: 7 
  end
end
