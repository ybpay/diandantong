module Ddt
  module Api
    module Rendering
      extend ActiveSupport::Concern

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

      def render_resource_created(resource, serializer: nil)
        render_resource(resource, serializer: serializer, status: :created)
      end

      def render_empty_success(message: "操作成功")
        render json: { data: { message: message } }, status: :ok
      end

      def render_errors(errors, status: :unprocessable_entity)
        error_objects = errors.map do |attr, msg|
          {
            status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status],
            source: { pointer: "/data/attributes/#{attr}" },
            detail: msg
          }
        end
        render json: { errors: error_objects }, status: status
      end
    end
  end
end
