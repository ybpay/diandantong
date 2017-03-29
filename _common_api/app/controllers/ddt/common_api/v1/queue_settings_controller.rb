module Ddt
  module CommonApi
    module V1
      class QueueSettingsController < V1::BaseController

        def index
          @queue_settings = @current_branch.queue_settings
          fresh_when(@queue_settings)
        end

      end
    end
  end
end
