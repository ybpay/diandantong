module Ddt
  module Api
    module V1
      module Agentsys
        class ShopsController < Ddt::Api::V1::BaseController
          def index
            shops = current_account.agent_shops.ransack(params[:q]).result
            render_paginated(shops)
          end

          def show
            shop = current_account.agent_shops.find(params[:id])
            render_resource(shop)
          end
        end
      end
    end
  end
end
