module Ddt
  class Weixin::PromotionsController < WeixinApplicationController
    before_action :set_promotion, only: [:show]
    def index
      @promotions = @current_shop.promotions_including_branch.active
      fresh_when(@promotions)
    end

    def show

    end

    private
    def set_promotion
      @promotion = @current_shop.promotions_including_branch.active.find(params[:id])
    end

  end
end