module Ddt
  module Webpos
    class CableController < Webpos::BaseController

      def load_config
        if current_account
          render json: {
            channel: "WebposChannel",
            account_id: current_account.id
          }
        else
          render json: { errors: 'current_account not login' }, status: :bad_request
        end
      end

    end
  end
end
