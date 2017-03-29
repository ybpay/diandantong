# encoding: utf-8
module Ddt
  class Backend::Admin::ApiKeysController < Backend::BaseAdminController
    before_action :set_api_key, only: [:show, :edit, :update, :destroy]

    respond_to :html

    def index
      @q = Ddt::ApiKey.all.ransack(params[:q])
      @api_keys = @q.result.distinct.paginate(:page => params[:page], :per_page => 25)
    end

    def show
    end

    def new
      @api_key = Ddt::ApiKey.new
    end

    def edit
    end

    def create
      @api_key = Ddt::ApiKey.new(api_key_params)
      if @api_key.save
        redirect_to [:backend, @api_key], notice: '创建成功'
      else
        render :new
      end
    end

    def update
      @api_key.update(api_key_params)
      if @api_key.save
        redirect_to [:backend, @api_key], notice: '更新成功'
      else
        render :edit
      end
    end

    def destroy
      @api_key.destroy
      redirect_to [:backend, @api_key], notice: '删除成功'
    end

    private
      def set_api_key
        @api_key = Ddt::ApiKey.find(params[:id])
      end

      def api_key_params
        params.require(:api_key).permit(:name)
      end
  end
end
