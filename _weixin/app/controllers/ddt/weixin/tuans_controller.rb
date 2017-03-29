module Ddt
  class Weixin::TuansController < WeixinApplicationController
    before_filter :set_tuan, only: [:show]

    def index
      @query = @current_shop.abstract_coupon_versions.tuans_on_sale.ransack(params[:query])
      @tuans = @query.result
      fresh_when(@tuans)
    end

    def show
    end

    private
    def set_tuan
      @tuan = @current_shop.abstract_coupon_versions.find(params[:id])
    end

  end
end
