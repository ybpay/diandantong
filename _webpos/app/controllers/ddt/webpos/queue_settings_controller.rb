module Ddt
  module Webpos
    class QueueSettingsController < Webpos::BaseController
      include Ddt::Webpos::QueueBill

      check_permission :branch, :guest_queue, {
        [:index, :history, :queue_states] => :show,
        create_guest_queue: :create
      }, except: [:set_notify_number_in_advance]
      check_permission :branch, :queue_setting, {
        [:set_notify_number_in_advance] => :update
      }, only: [:set_notify_number_in_advance]
      def index
        @queue_settings = @current_branch.queue_settings
        fresh_when(@queue_settings)
      end

      def history
        @q = @current_branch.guest_queues.ransack(params[:q])
        @guest_queues = @q.result(distinct: true).paginate(page: params[:page], per_page: (params[:per_page] || 20))
        render '/ddt/webpos/guest_queues/index'
      end

      def queue_states
        render json: @current_branch.queue_states_json
      end

      def create_guest_queue
        if @current_branch.arranging_setting.is_auto_assigned?
          @queue_setting = Ddt::QueueSetting.find_available_queue(guest_queue_param[:guest_num], @current_branch)
        elsif @current_branch.arranging_setting.is_free_choice?
          @queue_setting = Ddt::QueueSetting.find_by_id(guest_queue_param[:queue_setting_id])
        end
        if @queue_setting
          @guest_queue = @queue_setting.new_guest_queue(guest_queue_param.merge(terminal_id: params[:terminal_id]))
          @current_branch.reload
          if @guest_queue.valid?
            result = {
              queue_states: @current_branch.queue_states_json,
              queue_setting_id: @queue_setting.id,
              guest_num_at_front: @guest_queue.guest_num_at_front,
            }
            result[:bill] = queue_bill(@guest_queue)
            render json: result
          else
            render json: { errors: @guest_queue.errors.full_messages }, status: :bad_request
          end
        else
          render json: { errors: I18n.t('no queue_setting for this branch') }, status: :bad_request
        end
      end

      def set_notify_number_in_advance
        @queue_setting = @current_branch.queue_settings.find(params[:id])
        if @queue_setting.update(:notify_number_in_advance => params[:notify_number_in_advance])
          @queue_settings = @current_branch.queue_settings
          render :index
        else
          render json: {errors: @queue_setting.errors.full_messages}, status: :bad_request
        end
      end

      private

      def guest_queue_param
        params.require(:guest_queue).permit(:guest_num, :queue_setting_id, :phone, :is_local_printed)
      end
    end
  end
end
