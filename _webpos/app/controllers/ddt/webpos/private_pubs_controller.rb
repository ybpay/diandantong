module Ddt
  module Webpos
    class PrivatePubsController < Webpos::BaseController

      def load_config
        if current_account
          channel = Ddt::WebposNotify.channel(current_account.id)
          config = PrivatePub.subscription(channel: channel)
          render json: config.to_json
        else
          render json: { errors: 'current_account not login' }, status: :bad_request
        end
      end

    end
  end
end