module Ddt
  module Api
    module V1
      class ShopsController < BaseController
        def index
          shops = if current_account.is_admin?
                    Ddt::Shop.all
                  else
                    Ddt::Shop.where(id: current_account.shop_id)
                  end

          shops = shops.ransack(params[:q]).result
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
