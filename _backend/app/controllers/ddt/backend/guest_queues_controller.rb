module Ddt
  class Backend::GuestQueuesController < Backend::BaseController
    check_permission :branch, :guest_queue, { [:index, :show] => :show, [:edit, :update] => :update, pass: :pass, accept: :accept, cancel: :cancel, notify: :notify}
    before_action :set_queue_setting
    before_action :set_guest_queue, only: [:show, :edit, :update, :destroy, :pass, :cancel, :accept, :notify]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/queue_setting' }

    def index
      @q = @guest_queue_collection.ransack(params[:q])
      @guest_queues = @q.result.paginate(page: params[:page])
    end

    def show
    end

    def edit
    end

    def update
      if @guest_queue.update(guest_queue_params)
        redirect_to [:backend, @current_shop, @current_branch, @guest_queue.queue_setting, @guest_queue], notice: "#{t('activerecord.models.ddt/guest_queue')} 更新成功."
      else
        render :edit
      end
    end

    def pass
      @guest_queue.pass!
      redirect_to backend_shop_branch_queue_setting_guest_queues_path(@current_shop, @current_branch, @guest_queue.queue_setting, q: {workflow_state_eq: 'queueing'}), notice: '操作成功'
    end

    def accept
      @guest_queue.accept!
      redirect_to backend_shop_branch_queue_setting_guest_queues_path(@current_shop, @current_branch, @guest_queue.queue_setting, q: {workflow_state_eq: 'queueing'}), notice: '操作成功'
    end

    def cancel
      @guest_queue.cancel!
      redirect_to backend_shop_branch_queue_setting_guest_queues_path(@current_shop, @current_branch, @guest_queue.queue_setting, q: {workflow_state_eq: 'queueing'}), notice: '操作成功'
    end

    def notify
      @guest_queue.notify
      redirect_to backend_shop_branch_queue_setting_guest_queues_path(@current_shop, @current_branch, @guest_queue.queue_setting, q: {workflow_state_eq: 'queueing'}), notice: '操作成功'
    end

    private
      def set_queue_setting
        if params[:queue_setting_id]
          @queue_setting = @current_branch.queue_settings.find(params[:queue_setting_id])
          @guest_queue_collection = @queue_setting.guest_queues
        else
          @guest_queue_collection = @current_branch.guest_queues
        end
      end

      def set_guest_queue
        @guest_queue = @guest_queue_collection.find(params[:id])
      end

      def guest_queue_params
        params.require(:guest_queue).permit(:guest_no, :workflow_state, :is_notified, :base_user_id, :phone, :guest_num)
      end
  end
end
