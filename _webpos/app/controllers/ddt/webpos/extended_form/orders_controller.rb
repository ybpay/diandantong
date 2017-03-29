module Ddt
  module Webpos
    module ExtendedForm
      class OrdersController < Ddt::BaseController
        before_action :set_current_shop
        layout 'ddt/layouts/webpos/extended_form'
        def show
          @order = @current_shop.orders.find(params[:id])
        end
      end
    end
  end
end