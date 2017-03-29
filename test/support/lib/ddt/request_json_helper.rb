module Ddt
  module RequestJsonHelper
    extend ActiveSupport::Concern
    included do
      def json
        JSON.parse(response.body)
      end
    end
  end
end