class AddSupportRefundToBaseCoupon < ActiveRecord::Migration
  def change
    add_column :ddt_base_coupons, :support_refund, :boolean, default: false
    add_column :ddt_base_coupons, :refundable_days_after_send, :integer, default: 7
  end
end
