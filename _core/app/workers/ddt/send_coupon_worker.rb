# encoding: utf-8
module Ddt
  class SendCouponWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 5, :queue => :hardly

    def perform(attrs={})
      Ddt::SendCoupon.new(attrs).perform
    end

    def self.send_to_all_user(shop_id, coupon_version_id)
      to_user_ids = Ddt::BaseUser.joins(:vip_info).where(shop_id: shop_id).pluck(:id)
      perform_async(shop_id: shop_id, coupon_version_id: coupon_version_id, to_user_ids: to_user_ids)
    end

  end
end
