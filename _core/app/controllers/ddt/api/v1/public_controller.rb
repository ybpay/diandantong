module Ddt
  module Api
    module V1
      class PublicController < ActionController::Base
        include Ddt::Api::ErrorHandling
        include Ddt::Api::Rendering

        protect_from_forgery with: :null_session
        skip_before_action :verify_authenticity_token

        respond_to :json

        private

        def current_account
          @current_account
        end
      end
    end
  end
end
