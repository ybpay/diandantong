#encoding: utf-8
module Ddt
  module Schedule
    class DeleteOldMessageReceptionWorker < Ddt::Schedule::Base
      sidekiq_options :retry => 0, :queue => :hardly
      def perform
        Rails.logger.info("about to delete message reception records before #{15.days.ago}")
        Ddt::MessageReception.where('updated_at < ?', 15.days.ago).delete_all
      end
    end
  end
end
