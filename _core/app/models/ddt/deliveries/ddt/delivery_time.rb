#encoding: utf-8
module Ddt
  class DeliveryTime < Ddt::Base
    include Ddt::ListScope

    belongs_to :delivery_setting, touch: true
    acts_as_list scope: :delivery_setting
    default_scope ->{ list_order }

    validates_presence_of :start_time, :end_time
    validates_presence_of :cut_off_time, if: :enable_limit
    validates :delivery_setting, presence: true
    delegate :shop, to: :delivery_setting, allow_nil: true
    access_with_shop_time_zone :start_time, :end_time, :cut_off_time

    def self.valid(today: true)
      today ? all.select{|delivery_time| delivery_time.valid_today? } : all
    end

    def valid_today?
      now = shop_time_now
      return false if time_a_early_than_b(end_time, now)
      return true unless enable_limit
      return time_a_early_than_b(now, cut_off_time)
    end

    def time_a_early_than_b(a, b)
      Ddt::TimeUtil.time_a_early_than_b(a,b)
    end

    def fstart_time
      self.start_time.strftime("%H:%M")
    end

    def fend_time
      self.end_time.strftime("%H:%M")
    end

    def display
      [fstart_time, fend_time].join("~")
    end

  end
end