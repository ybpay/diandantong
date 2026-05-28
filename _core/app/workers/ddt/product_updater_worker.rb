#encoding: utf-8
module Ddt
  class ProductUpdaterWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 2, :queue => :seldom
    def perform(branch_id, version)
      branch = Ddt::Branch.find(branch_id)
      if branch.products_cache_version.present? && branch.products_cache_version.to_s == version.to_s
        msg = notification_msg_view(branch_id, version)
        branch.order_related_people.each do |account|
          WebposChannel.broadcast_to(account, msg)
        end
      end
    end

    def notification_msg_view(branch_id, version)
      {
        type: 'PRODUCT_UPDATE_NOTIFICATION',
        created_at: version,
        branch_id: branch_id,
      }
    end
  end
end
