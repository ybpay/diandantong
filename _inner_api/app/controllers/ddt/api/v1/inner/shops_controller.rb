module Ddt
  module Api
    module V1
      module Inner
        class ShopsController < Ddt::Api::V1::Inner::BaseController
          def index
            shops = Ddt::Shop.ransack(params[:q]).result
            render json: { data: shops.map(&:as_api_json) }
          end

          def show
            shop = Ddt::Shop.find(params[:id])
            render json: { data: shop.as_api_json }
          end
        end
      end
    end
  end
end
