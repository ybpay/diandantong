# encoding : utf-8
module Ddt
  class Backend::Admin::AppVersionsController < Backend::BaseAdminController

    before_action :set_app_version, only: [:show, :edit, :update, :destroy]

    def index
      @q = Ddt::AppVersion.ransack(params[:q])
      @app_versions = @q.result.paginate(page: params[:page])
    end

    def show
    end

    def new
      @app_version = Ddt::AppVersion.new
    end

    def edit
    end

    def create
      @app_version = Ddt::AppVersion.new(app_version_params)

      if @app_version.save
        redirect_to [:backend, @app_version], notice: "#{t('activerecord.models.ddt/app_version')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @app_version.update(app_version_params)
        redirect_to [:backend, @app_version], notice: "#{t('activerecord.models.ddt/app_version')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @app_version.destroy
        redirect_to backend_app_versions_url, notice: "#{t('activerecord.models.ddt/app_version')} 删除成功."
      else
        flash[:error] = @app_version.errors.full_messages.join('<br/>')
        redirect_to backend_app_versions_url
      end
    end

    private
      def set_app_version
        @app_version = Ddt::AppVersion.find(params[:id])
      end

      def app_version_params
        params.require(:app_version).permit(:os_type, :terminal, :version_name, :version_code, :note, :url)
      end
  end
end
