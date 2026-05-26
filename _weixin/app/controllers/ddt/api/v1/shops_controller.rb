module Ddt
  module Api
    module V1
      module Weixin
        class ShopsController < Ddt::Api::V1::BaseController
          skip_before_action :authenticate_api_account!, only: [:index, :show]

          def index
            shops = Ddt::Shop.ransack(params[:q]).result
            render_paginated(shops)
          end

          def show
            shop = Ddt::Shop.find(params[:id])
            render_resource(shop)
          end
        end
      end
    end
  end
end
