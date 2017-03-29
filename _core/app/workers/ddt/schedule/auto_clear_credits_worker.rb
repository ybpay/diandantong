module Ddt
  module Schedule
    class AutoClearCreditsWorker < Ddt::Schedule::Base
      def perform
        shop_ids = Ddt::CreditsSetting.where(auto_clear_credits: true).pluck(:shop_id)
        Ddt::Shop.find(shop_ids).each do |shop|
          shop.vip_infos.not_default_level.where("ddt_vip_infos.created_at < ?", 1.year.ago).find_each do |vip_info|
            vip_info.credits_wallet.credits_clear
          end
        end
      end
    end
  end
end
