#encoding: utf-8
module Ddt
  module Schedule
    class ClearStatisticsCacheWorker < Ddt::Schedule::Base
      sidekiq_options :retry => 0, :queue => :hardly
      def perform
        Ddt::StatisticsCache.where(state: :exception).where('updated_at < ?', 30.minutes.ago).delete_all
      end
    end
  end
end
