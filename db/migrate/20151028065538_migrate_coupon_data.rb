class MigrateCouponData < ActiveRecord::Migration
  def change
    Ddt::AbstractCouponVersion.with_deleted.joins(:base_coupons)
    .where('ddt_base_coupons.expires_at < ddt_abstract_coupon_versions.usable_expires_at')
    .update_all(%Q{
      ddt_base_coupons.usable_expires_at = expires_at,
      ddt_base_coupons.usable_starts_at = ddt_abstract_coupon_versions.usable_starts_at
    })

    Ddt::AbstractCouponVersion.with_deleted.joins(:base_coupons)
    .where('ddt_base_coupons.expires_at >= ddt_abstract_coupon_versions.usable_expires_at')
    .update_all(%Q{
      ddt_base_coupons.usable_expires_at = ddt_abstract_coupon_versions.usable_expires_at,
      ddt_base_coupons.usable_starts_at = ddt_abstract_coupon_versions.usable_starts_at

      })
  end
end
