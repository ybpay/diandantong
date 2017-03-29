module Ddt
  class Backend::HomeHotLinksController < Backend::BaseController
    check_permission :shop, :wechat_config, { [:index, :show] => :show, [:new, :create, :edit, :update, :destroy, :change_position] => :update}
    before_action :set_custom_weixin_info
    before_action :set_home_hot_link, only: [:show, :edit, :update, :destroy, :change_position]
    layout 'ddt/layouts/backend/shop'

    def index
      @home_hot_links = @custom_weixin_info.home_hot_links.where(is_multiple: @current_shop.max_branches_limit > 1)
    end

    def show
    end

    def new
      @home_hot_link = @custom_weixin_info.home_hot_links.build
    end

    def create
      @home_hot_link = @custom_weixin_info.home_hot_links.build(home_hot_link_params)
      @home_hot_link.is_multiple = (@current_shop.max_branches_limit  > 1)

      if @home_hot_link.save
        redirect_to [:backend, @current_shop, :custom_weixin_info, @home_hot_link]
      else
        render :new
      end
    end

    def edit

    end

    def update
      if @home_hot_link.update(home_hot_link_params)
        redirect_to [:backend, @current_shop, :custom_weixin_info, @home_hot_link]
      else
        render :new
      end
    end

    def destroy
      @home_hot_link.destroy
      redirect_to [:backend, @current_shop, :custom_weixin_info, :home_hot_links]
    end

    def change_position
      @home_hot_link.change_position(params[:position])
      respond_to do |format|
        format.js { render :reset }
      end
    end

    private
    def set_custom_weixin_info
      @custom_weixin_info = @current_shop.custom_weixin_info
    end

    def set_home_hot_link
      @home_hot_link = @custom_weixin_info.home_hot_links.find(params[:id])
    end

    def home_hot_link_params
      params.require(:home_hot_link).permit(:label, :icon, :icon_background_color, :image, :remove_image, :image_cache, :link)
    end
  end
end