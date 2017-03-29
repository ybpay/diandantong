module Ddt
  class Backend::OrderCallsController < Backend::BaseController
    check_permission :shop, :call_setting, :show
    def index
      @q = @current_shop.order_calls.ransack(params[:q])
      @order_calls = @q.result.paginate(page: params[:page])
      render layout: 'ddt/layouts/backend/call_setting'
    end

  end
end
