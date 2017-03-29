module Ddt
  class BatchCreditsClearWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 0, :queue => :seldom
    def perform(shop_id, vip_info_ids)
      shop = Ddt::Shop.find(shop_id)
      shop.vip_infos.where(id: vip_info_ids).find_each do |vip_info|
        vip_info.credits_wallet.credits_clear
      end
    end
  end
end
