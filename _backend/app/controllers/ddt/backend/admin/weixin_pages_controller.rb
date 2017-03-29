#encoding: utf-8
module Ddt
  module Backend
    class Admin::WeixinPagesController < Ddt::Backend::BaseAdminController
      before_action :set_weixin_page, only: [:show, :edit, :update]
      def index
        @weixin_pages = @current_shop.weixin_pages
      end

      def new
        @weixin_page = @current_shop.weixin_pages.new
      end

      def create
        if @current_shop.weixin_pages.create!(weixin_page_params)
          @current_shop.touch
          redirect_to backend_shop_weixin_pages_path(@current_shop), notice: "创建成功"
        else
          render 'new'
        end
      end

      def edit
      end

      def update
        if @weixin_page.update(weixin_page_params)
          @current_shop.touch 
          redirect_to backend_shop_weixin_pages_path(@current_shop), notice: "更新成功"
        else
          render action: 'edit'
        end
      end

      private 
      def set_weixin_page
        @weixin_page = @current_shop.weixin_pages.find(params[:id])
      end

      def weixin_page_params
        params.require(:weixin_page).permit(:url, :template_type)
      end

    end
  end
end