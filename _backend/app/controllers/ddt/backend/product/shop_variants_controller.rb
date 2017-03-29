module Ddt
  class Backend::Product::ShopVariantsController < Backend::BaseController


    def index
      @q = @current_shop.variants.ransack(params[:q])
      @variants = @q.result.group(:sku).distinct.paginate(page: params[:page])
      respond_to do |format|
        format.json {
          render json: @variants.flatten.map(&:sku_json)
        }
      end
    end

  end
end
