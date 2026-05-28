module Ddt
  module Api
    module V1
      module Backend
        class PrintersController < Ddt::Api::V1::BaseController
          before_action :set_shop

          def index
            printers = @shop.printers.ransack(params[:q]).result.distinct
            render_paginated(printers)
          end

          def show
            printer = @shop.printers.find(params[:id])
            render_resource(printer)
          end

          private

          def set_shop
            @shop = current_account.is_admin? ? Ddt::Shop.find(params[:shop_id]) : current_account.shop
          end
        end
      end
    end
  end
end
