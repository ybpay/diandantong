#encoding: utf-8
module Ddt
  module Schedule
    class VipBirthdayNotificationWorker < Ddt::Schedule::Base
      def perform
        Ddt::Shop.can_send_birthday_sms.find_each do |shop|
          shop.send_birthday_sms_to_vips
        end

        promotions = Ddt::Promotion.includes(:promotion_rules).where(ddt_promotion_rules: {type: 'Ddt::Promotion::Rules::Event::VipBirthday'}).active
        promotions.each do |promotion|
          advance_days = promotion.promotion_rules.detect{|r| r.class.name == 'Ddt::Promotion::Rules::Event::VipBirthday'}.preferred_advance_days
          promotion.shop.send_birthday_promotion(advance_days: advance_days)
        end
      end
    end
  end
end


