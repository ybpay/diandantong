module Ddt
  class ServicePeriod < Ddt::Base
    include BelongsToBranchWithTouch
    validates :start_at, :end_at, :presence =>true
    validate :start_not_equal_to_end
    access_with_shop_time_zone :start_at, :end_at

    def is_in_service_time?(now)
      now_time = Ddt::TimeUtil.time_since_beginning_of_day(now.in_time_zone(shop.shop_time_zone))
      start_time = Ddt::TimeUtil.time_since_beginning_of_day(start_at)
      end_time = Ddt::TimeUtil.time_since_beginning_of_day(end_at)
      if start_time <= end_time
        start_time <= now_time and now_time < end_time
      else
        start_time <= now_time or now_time < end_time
      end
    end

    def fstart_at
      self.start_at.strftime("%H:%M")
    end

    def fend_at
      self.end_at.strftime("%H:%M")
    end

    def display
      [fstart_at, fend_at].join("~")
    end

    private
    def start_not_equal_to_end
      self.errors.add(:base, I18n.t('activerecord.errors.messages.service_periods.start_at.equal')) if self.start_at == self.end_at
    end
  end
end
