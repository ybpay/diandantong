module Ddt
  class Backend::PrintersController < Backend::BaseController
    def index
      @q = @current_shop.printers.ransack(params[:q])
      @printers = @q.result(distinct: true).paginate(page: params[:page])
      respond_to do |format|
        format.json { render json: @printers.map(&:select_json) }
      end
    end
  end
end
