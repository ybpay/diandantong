module Ddt
  module CommonApi
    module V1
      class RolesController < V1::BaseController

        def index
          @roles = @current_shop.roles
          render json: @roles.map(&:select_json)
        end

      end
    end
  end
end
