#encoding: utf-8
module Ddt
  module Schedule
    class CleanDbWorker < Ddt::Schedule::Base
      sidekiq_options :retry => 0, :queue => :hardly

      def perform
        ts = 10.days.ago
        
            # Ddt::Notification,
            # Ddt::NotificationAction,
            # Ddt::NotificationEvent,
        [
            Impression,
            Ddt::AppNotificationCache,
            Ddt::JsError,
            Ddt::JsErrorCount,
            Ddt::Location,
            Ddt::MessageReception,
            Ddt::MessageResponse,
            Ddt::MessageResponseItem,
            Ddt::StatisticsCache
        ].each do |model|
          Rails.logger.info("about to delete #{model.to_s} before #{ts}")
          model.where('created_at < ?', ts).delete_all
        end

        ts = 30.days.ago
        [
            Ddt::PrintRecord,
            Ddt::PaymentLog
        ].each do |model|
          Rails.logger.info("about to delete #{model.to_s} before #{ts}")
          model.where('created_at < ?', ts).delete_all
        end

      end
    end
  end
end
