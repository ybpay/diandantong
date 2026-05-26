# encoding : utf-8
module Ddt
  class Backend::Admin::QrCodeScenesController < Backend::BaseAdminController
    before_action :set_qr_code_scene, only: [:show, :edit, :update, :destroy]
    def index
      @q = Ddt::QrCodeScene.ransack(params[:q])
      @q.sorts = 'id desc' 
      @qr_code_scenes = @q.result.paginate(page: params[:page])
    end


    def show
    end

    
    def update
      if @qr_code_scene.update(qr_code_scene_params)
        redirect_to [:backend, @qr_code_scene], notice: "#{t('activerecord.models.ddt/qr_code_scene')} 更新成功."
      else
        render :edit
      end
    end

    def batch_new
      # Ddt::QrCodeScene.import
    end

    def batch_create
      count = batch_qr_code_scenes_params[:count].to_i
      if count > 0
        Ddt::QrCodeSceneBatchCreateWorker.perform_in(1.second, count)
        redirect_to [:backend, :qr_code_scenes], alert: "创建#{result[:num_inserts]}/#{count}张正在进行中"
      else
        redirect_to :batch_new, flash: {error: '数量不能小于0'}
      end
    end


    private 
    def set_qr_code_scene
      @qr_code_scene = Ddt::QrCodeScene.find(params[:id])
    end

    def qr_code_scene_params
      params.require(:qr_code_scene).permit(:slug, :shop_id, :is_enable, :preferred_redirect_url, :branch_id)
    end

    def batch_qr_code_scenes_params
      params.require(:batch_qr_code_scenes).permit(:count, :shop_id, :branch_id)
    end
  end
end