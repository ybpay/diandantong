module Ddt
  class Notification
    module ActionWorker
      class Critical < Ddt::Notification::ActionWorker::Base
        sidekiq_options :retry => 5, :queue => :critical
      end
    end
  end
end
