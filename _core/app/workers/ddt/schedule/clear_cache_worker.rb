#encoding: utf-8
module Ddt
  module Schedule
    class ClearCacheWorker < Ddt::Schedule::Base
      sidekiq_options :retry => 0, :queue => :hardly
      def perform
        Rails.cache.clear
        # ActiveStorage handles its own cache cleanup
      end
    end
  end
end
