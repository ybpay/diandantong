class AddLastSendCouponToAllToShop < ActiveRecord::Migration
  def change
    add_column :ddt_shops, :last_send_coupon_to_all, :datetime
  end
end
