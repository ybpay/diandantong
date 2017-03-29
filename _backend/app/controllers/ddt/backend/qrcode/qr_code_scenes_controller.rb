module Ddt
  class Backend::Qrcode::QrCodeScenesController < Backend::BaseController
    check_permission :shop, :qrcode, base_permission_actions
    before_action :set_qr_code_scene, only: [:show, :edit, :update, :destroy, :edit_bind, :update_bind]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/base_qr_code_scene' }

    def index
      @q = @current_shop.qr_code_scenes.of_custom.ransack(params[:q])
      @qr_code_scenes = @q.result.paginate(page: params[:page])
    end

    def show
    end

    def edit_bind
      @branch = @current_shop.branches.find(@qr_code_scene.branch_id)
    end

    def update_bind
      @table = Ddt::Table.find(qr_code_scene_params[:owner_id])
      if @qr_code_scene.update_attributes(:name => @table.name, :owner => @table, :builtin => true)
        redirect_to request.referer, notice: '绑定成功'
      else
        redirect_to request.referer, notice: "绑定失败：失败原因：#{@qr_code_scene.errors.full_messages.join('<br/>')}"
      end
    end

    def new
      @qr_code_scene = @current_shop.qr_code_scenes.build
    end

    def edit
    end

    def create
      @qr_code_scene = @current_shop.qr_code_scenes.of_custom.build(qr_code_scene_params)

      if @qr_code_scene.save
        redirect_to [:backend, @current_shop, @qr_code_scene], notice: "#{t('activerecord.models.ddt/qr_code_scene')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @qr_code_scene.update(qr_code_scene_params)
        redirect_to [:backend, @current_shop, @qr_code_scene], notice: "#{t('activerecord.models.ddt/qr_code_scene')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @qr_code_scene.destroy
        redirect_to backend_shop_qr_code_scenes_url(@current_shop), notice: "#{t('activerecord.models.ddt/qr_code_scene')} 删除成功."
      else
        flash[:error] = @qr_code_scene.errors.full_messages.join('<br/>')
        redirect_to backend_shop_qr_code_scenes_url(@current_shop)
      end
    end

    private
      def set_qr_code_scene
        @qr_code_scene = @current_shop.qr_code_scenes.of_custom.friendly.find(params[:id])
      end

      def qr_code_scene_params
        params.require(:qr_code_scene).permit(:name, :preferred_redirect_url, :owner_id, :owner_type)
      end
  end
end