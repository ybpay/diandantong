#encoding: utf-8
module Ddt
  module Schedule
    class ClearCacheWorker < Ddt::Schedule::Base
      sidekiq_options :retry => 0, :queue => :hardly
      def perform
        Rails.cache.clear
        CarrierWave.clean_cached_files!
      end
    end
  end
end
