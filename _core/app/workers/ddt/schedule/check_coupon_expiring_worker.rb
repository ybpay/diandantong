module Ddt
  module Schedule
    class CheckCouponExpiringWorker < Ddt::Schedule::Base
      def perform
        Ddt::CouponSetting.where(enable_expired_notify: true).find_each do |coupon_setting|
          advance_days = coupon_setting.expired_notify_in_advance_days
          time_interval = advance_days.days.since.beginning_of_day..advance_days.days.since.end_of_day
          coupon_setting.shop.coupons.available.where(expires_at: time_interval).find_each do |coupon|
            Ddt::Notification::Event::Coupon::Expiring.create_and_send_notification(base_coupon: coupon)
          end
        end
      end
    end
  end
end
