module Ddt
  module OauthApi
    class BaseController < Ddt::BaseController
      before_action :doorkeeper_authorize!
      before_action :set_current_shop
      def current_account
        @current_account ||= Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end
  end
end
