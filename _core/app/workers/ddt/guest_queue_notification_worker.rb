# encoding: utf-8
module Ddt
  class GuestQueueNotificationWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 5, :queue => :critical

    def perform(notification_id)
      notification = Ddt::GuestQueueNotification.find(notification_id)
      guest_queue = notification.guest_queue

      material_options = {
        title: title,
        description: desc
      }
      self.shop.notify_to(guest_queue.base_user, material_options)
    end

  end
end
