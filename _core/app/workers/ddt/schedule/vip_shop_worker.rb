require 'yaml'
module Ddt
  module Schedule
    class VipShopWorker < Ddt::Schedule::Base

      def perform
        yixiu_send_coupon_30days
      end
      #伊秀的个性化需求，若干个月后届时可以删除
      def yixiu_send_coupon_30days
        start_day = Time.new(2016, 10, 25, 0, 0, 0) # 星期二 凌晨开始跑，跑星期一的数据
        end_day = start_day + 200.days
        now = Time.now
        if start_day < now and now < end_day
          coupon_version = Ddt::CouponVersion.find 4071
          shop = Ddt::Shop.find_by(slug: 'yixiu')
          file_path = File.expand_path('../../../tmp/yixiu_vip_no_list.yml', __FILE__)
          vip_nos = YAML.load_file(file_path)
          vip_nos.each_slice(200) do |nos|
            vip_infos = shop.vip_infos.where(vip_no: nos)
            vip_infos.each do |vip_info|
              user = vip_info.user
              if user.present? && !vip_info.vip_level.is_default?
                count = user.coupons.where(abstract_coupon_version_id: coupon_version.id).count
                coupon_version.send_coupon_to_user(user, 'system') if count == 0
              end
            end
          end
        end
      end

    end
  end
end
