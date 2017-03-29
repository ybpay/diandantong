module Ddt
  class CouponSetting < Ddt::Base
    include BelongsToShop
    # enable_expired_notify
    # expired_notify_in_advance_days
  end
end