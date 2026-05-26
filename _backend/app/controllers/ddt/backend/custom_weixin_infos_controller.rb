module Ddt
  class Backend::CustomWeixinInfosController < Backend::BaseController
    check_permission :shop, :wechat_config, {[:edit, :update] => :update}
    before_action :set_custom_weixin_info, only: [:show, :update, :edit]
    layout 'ddt/layouts/backend/shop'

    def edit
    end

    def update
      if @custom_weixin_info.update(custom_weixin_info_params)
        redirect_to [:edit, :backend, @current_shop, :custom_weixin_info], notice: '更新成功'
      else
        render action: 'edit'
      end
    end

    private
    def set_custom_weixin_info
      @custom_weixin_info = @current_shop.custom_weixin_info
    end

    def custom_weixin_info_params
      params.require(:custom_weixin_info).permit(:layout_type, :branch_index_layout, :background_image, :background_image_cache, :remove_background_image)
    end
  end
end