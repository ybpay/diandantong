module Ddt
  class Backend::ExchangeCodesController < Backend::BaseController
    check_permission :shop, :exchange_code, { index: :show, exchange: :exchange }
    before_action :set_exchange_code, only: [:exchange]

    def index
      @q = @current_shop.exchange_codes.ransack(params[:q])
      @exchange_codes = @q.result.paginate(page: params[:page])
    end

    def exchange
      respond_to do |format|
        format.js do
          if @exchange_code.can_exchange_by?(current_account)
            @exchange_code.exchange
            render :reset
          else
            @error = "没有权限"
            render :error
          end
        end
      end
    end

    private
    def set_exchange_code
      @exchange_code = @current_shop.exchange_codes.find(params[:id])
    end
  end
end