module Ddt
  module Api
    module Admin
      module V1
        class BaseController < Ddt::Api::V1::BaseController
          private

          def current_shop
            @current_shop ||= super || current_account&.shop
          end
        end
      end
    end
  end
end
