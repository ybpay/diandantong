class FixAbstractCouponVersion < ActiveRecord::Migration
  def change
    Ddt::AbstractCouponVersion.where(expired_type: :after_send_expired_time).update_all(usable_starts_at: nil, usable_expires_at: nil)
  end
end
