class FixSharableCoupon < ActiveRecord::Migration
  def change
    Ddt::SharableCoupon.where(abstract_coupon_version_id: nil).delete_all
  end
end
