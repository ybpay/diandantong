#encoding: utf-8
module Ddt
  class ProductUpdaterWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 2, :queue => :seldom
    def perform(branch_id, version)
      branch = Ddt::Branch.find(branch_id)
      if branch.products_cache_version.present? && branch.products_cache_version.to_s == version.to_s
        msg = notificaiton_msg_view(branch_id, version)
        branch.order_related_people.each do |account|
          channel = Ddt::WebposNotify.channel(account.id)
          PrivatePub.publish_to(channel, msg: msg)
        end
      end
    end


    def notificaiton_msg_view(branch_id, version)
      {
        type: 'PRODUCT_UPDATE_NOTIFICATION',
        created_at: version,
        branch_id: branch_id,
      }
    end
  end
end
