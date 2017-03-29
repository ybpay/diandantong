module Ddt
  class Backend::HomeUsableLinksController < Backend::BaseController
    check_permission :shop, :wechat_config, { [:index, :show] => :show, [:new, :create, :edit, :update, :destroy, :change_position] => :update}
    before_action :set_custom_weixin_info
    before_action :set_home_usable_link, only: [:show, :edit, :update, :destroy, :change_position]
    layout 'ddt/layouts/backend/shop'

    def index
      @home_usable_links = @custom_weixin_info.home_usable_links
    end

    def show
    end

    def new
      @home_usable_link = @custom_weixin_info.home_usable_links.build
    end

    def create
      @home_usable_link = @custom_weixin_info.home_usable_links.build(home_usable_link_params)
      if @home_usable_link.save
        redirect_to [:backend, @current_shop, :custom_weixin_info, @home_usable_link]
      else
        render :new
      end
    end

    def edit

    end

    def update
      if @home_usable_link.update(home_usable_link_params)
        redirect_to [:backend, @current_shop, :custom_weixin_info, @home_usable_link]
      else
        render :new
      end
    end

    def destroy
      @home_usable_link.destroy
      redirect_to [:backend, @current_shop, :custom_weixin_info, :home_usable_links]
    end

    def change_position
      @home_usable_link.change_position(params[:position])
      respond_to do |format|
        format.js { render :reset }
      end
    end

    private
    def set_custom_weixin_info
      @custom_weixin_info = @current_shop.custom_weixin_info
    end

    def set_home_usable_link
      @home_usable_link = @custom_weixin_info.home_usable_links.find(params[:id])
    end

    def home_usable_link_params
      params.require(:home_usable_link).permit(:title, :keywords, :image, :remove_image, :image_cache, :link)
    end
  end
end