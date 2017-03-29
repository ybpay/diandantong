module Ddt
  class Backend::QueueSettingsController < Backend::BaseController
    check_permission :branch, :queue_setting, base_permission_actions.merge({board: :show})
    before_action :set_queue_setting, only: [:show, :edit, :update, :destroy]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/queue_setting' }


    def board
    end

    def index
      @q = @current_branch.queue_settings.ransack(params[:q])
      @queue_settings = @q.result.paginate(page: params[:page])
    end

    def show
    end

    def new
      @queue_setting = @current_branch.queue_settings.build(start_at: '00:00', end_at: '23:59')
    end

    def edit
    end

    def create
      @queue_setting = @current_branch.queue_settings.build(queue_setting_params)

      if @queue_setting.save
        redirect_to [:backend, @current_shop, @current_branch, @queue_setting], notice: "#{t('activerecord.models.ddt/queue_setting')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @queue_setting.update(queue_setting_params)
        redirect_to [:backend, @current_shop, @current_branch, @queue_setting], notice: "#{t('activerecord.models.ddt/queue_setting')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @queue_setting.destroy
        redirect_to backend_shop_branch_queue_settings_url(@current_shop, @current_branch), notice: "#{t('activerecord.models.ddt/queue_setting')} 删除成功."
      else
        flash[:error] = @queue_setting.errors.full_messages.join('<br/>')
        redirect_to backend_shop_branch_queue_settings_url(@current_shop, @current_branch)
      end
    end

    private
      def set_queue_setting
        @queue_setting = @current_branch.queue_settings.find(params[:id])
      end

      def queue_setting_params
        params.require(:queue_setting).permit(:name, :guest_num_le, :start_at, :end_at, :queue_no_prefix, :enabled, :notify_number_in_advance)
      end
  end
end
