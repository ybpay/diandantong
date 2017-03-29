module Ddt
  class Backend::Qrcode::WechatQrCodeScenesController < Backend::BaseController
    check_permission :shop, :qrcode, base_permission_actions
    before_action :set_wechat_qr_code_scene, only: [:show, :edit, :update, :destroy]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/base_qr_code_scene' }

    def index
      @q = @current_shop.wechat_qr_code_scenes.by_wechat_scene_type(:limit).ransack(params[:q])
      @wechat_qr_code_scenes = @q.result.paginate(page: params[:page])
    end

    def show
    end

    def new
      @wechat_qr_code_scene = @current_shop.wechat_qr_code_scenes.build
    end

    def edit
    end

    def create
      @wechat_qr_code_scene = @current_shop.wechat_qr_code_scenes.by_wechat_scene_type(:limit).of_custom.build(wechat_qr_code_scene_params)

      if @wechat_qr_code_scene.save
        redirect_to [:backend, @current_shop, @wechat_qr_code_scene], notice: "#{t('activerecord.models.ddt/wechat_qr_code_scene')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @wechat_qr_code_scene.update(wechat_qr_code_scene_params)
        redirect_to [:backend, @current_shop, @wechat_qr_code_scene], notice: "#{t('activerecord.models.ddt/wechat_qr_code_scene')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @wechat_qr_code_scene.destroy
        redirect_to backend_shop_wechat_qr_code_scenes_url(@current_shop), notice: "#{t('activerecord.models.ddt/wechat_qr_code_scene')} 删除成功."
      else
        flash[:error] = @wechat_qr_code_scene.errors.full_messages.join('<br/>')
        redirect_to backend_shop_wechat_qr_code_scenes_url(@current_shop)
      end
    end

    private
      def set_wechat_qr_code_scene
        @wechat_qr_code_scene = @current_shop.wechat_qr_code_scenes.of_custom.friendly.find(params[:id])
      end

      def wechat_qr_code_scene_params
        params.require(:wechat_qr_code_scene).permit(:name, :limit_scene_type, :branch_id, :material_id, :gonghao_open_id)
      end
  end
end
