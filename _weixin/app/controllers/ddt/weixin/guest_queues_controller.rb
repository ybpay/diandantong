module Ddt
  class Weixin::GuestQueuesController < WeixinApplicationController
    respond_to :json
    def show
      @queue_settings = @branch.queue_settings.includes(:queueing_guests)
      @my_queue = @current_user.guest_queues.of_current_queue.first rescue nil
      @last_guest_num_le = 0
      attach_adapter(@my_queue.id) if @my_queue.present?
    end

    def create
      if @branch.arranging_setting.is_auto_assigned?
        @queue_setting = QueueSetting.find_available_queue(guest_queue_params[:guest_num], @branch)
      elsif @branch.arranging_setting.is_free_choice?
        @queue_setting = QueueSetting.find_by_id(params[:guest_queue][:queue_setting_id])
      end
      if @queue_setting
        @guest_queue = @queue_setting.new_guest_queue(guest_queue_params.merge(base_user: @current_user))
        if @guest_queue.valid?
          attach_adapter(@guest_queue.id)
          render json: {}
        else
          render json: { errors: @guest_queue.errors.full_messages }, status: :bad_request
        end
      else
        render json: { errors: I18n.t('no queue_setting for this branch') }, status: :bad_request
      end
    end

    def cancel
      @my_queue = @current_user.guest_queues.of_current_queue.first rescue nil
      if @my_queue.blank?
        render json: { errors: "record not exist"}, status: :bad_request
      elsif @my_queue.cancel!
        Ddt::OrderItemable::Adapter.get_from(session).detach(session)
        render json: {}
      else
        render json: { errors: @my_queue.errors.full_messages }, status: :bad_request
      end
    end

    def bind_user
      @guest_queue = @branch.guest_queues.find(params[:guest_queue_id])
      if @guest_queue.bind_user(@current_user)
        render json: { state: true }
      else
        render json: { state: false, error: @guest_queue.errors.full_messages }
      end
    end

    def get_by_qr_code
      @qr_code_scene = @current_shop.base_qr_code_scenes.find(params[:qr_code_id])
      @guest_queue = @qr_code_scene.owner
    end

    private
    def attach_adapter(guest_queue_id)
      Ddt::OrderItemable::Adapter.new(
        store_type: 'for_pre_order',
        guest_queue_id: guest_queue_id
      ).attach(session)
    end

    def guest_queue_params
      params.require(:guest_queue).permit(:guest_num, :phone)
    end
  end
end
