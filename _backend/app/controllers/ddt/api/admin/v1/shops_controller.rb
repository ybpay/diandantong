module Ddt
  module Api
    module Admin
      module V1
        class ShopsController < BaseController
          def show
            render_resource(current_shop)
          end

          def update
            if current_shop.update(shop_params)
              render_resource(current_shop)
            else
              render_errors(current_shop.errors)
            end
          end

          private

          def shop_params
            params.require(:shop).permit(:name, :description, :contact_phone, :address)
          end
        end
      end
    end
  end
end
