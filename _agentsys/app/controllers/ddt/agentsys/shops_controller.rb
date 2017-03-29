# encoding: utf-8
module Ddt
  class Agentsys::ShopsController < Agentsys::BaseController

    before_action :set_shop, only: [:show, :edit, :update, :follow, :give_up]

    def index
     @q = current_agentsys_agent.shops.ransack(params[:q])
     @shops = @q.result(distinct: true).paginate(page: params[:page],:per_page => 25)

    end

    def show
      @current_agent = current_agentsys_agent
    end

    def edit
    end

    def update
      if @shop.update!(shop_params)
        redirect_to [:agentsys, @shop], notice: "#{t('activerecord.models.ddt/shop')} 修改成功."
      else
        render :edit
      end
    end

    def follow
      @shop.update_column(:is_give_up, false)
      render 'reset'
    end

    def give_up
      @shop.update_column(:is_give_up, true)
      render 'reset'
    end

    private
      def set_shop
        @shop = current_agentsys_agent.shops.find(params[:id]) rescue nil
      end

      def shop_params
        params.require(:shop).permit(:name, :is_ban)
      end

  end
end
