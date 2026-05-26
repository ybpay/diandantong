module Ddt
  module Api
    module V1
      class PublicController < ActionController::Base
        include Ddt::Api::ErrorHandling

        protect_from_forgery with: :null_session
        skip_before_action :verify_authenticity_token

        respond_to :json

        private

        def render_resource(resource, serializer: nil, status: :ok)
          json = if serializer
                   serializer.new(resource).as_json
                 elsif resource.respond_to?(:as_api_json)
                   resource.as_api_json
                 else
                   resource.as_json
                 end
          render json: { data: json }, status: status
        end
      end
    end
  end
end
