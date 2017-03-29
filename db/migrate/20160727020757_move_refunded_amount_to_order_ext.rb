class MoveRefundedAmountToOrderExt < ActiveRecord::Migration
  def change
     if column_exists? :ddt_orders, :refunded_amount
       remove_column :ddt_orders, :refunded_amount
     end
     unless column_exists? :ddt_order_exts, :refunded_amount
      add_column :ddt_order_exts, :refunded_amount, :decimal, precision: 10, scale:2, default: 0.0
     end
      Ddt::BaseCoupon.where.not(refund_at: nil).find_each do |coupon|
        coupon.order_ext.update!(refunded_amount: coupon.abstract_coupon_version.groupon_price)
      end
  end
end
