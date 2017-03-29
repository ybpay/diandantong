module Ddt
  class Notification
    module ActionWorker
      class Seldom < Ddt::Notification::ActionWorker::Base
        sidekiq_options :retry => 5, :queue => :seldom
      end
    end
  end
end
