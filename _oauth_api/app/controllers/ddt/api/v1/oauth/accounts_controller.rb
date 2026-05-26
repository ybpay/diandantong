module Ddt
  module Api
    module V1
      module Oauth
        class AccountsController < Ddt::Api::V1::BaseController
          skip_before_action :authenticate_api_account!

          before_action :doorkeeper_authorize!

          def show
            account = Account.find(doorkeeper_token.resource_owner_id)
            render_resource(account)
          end

          private

          def doorkeeper_token
            request.env["doorkeeper.token"]
          end
        end
      end
    end
  end
end
