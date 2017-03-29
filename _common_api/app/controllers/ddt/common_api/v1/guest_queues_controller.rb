module Ddt
  module CommonApi
    module V1
      class GuestQueuesController < V1::BaseController

        before_action :set_guest_queue, except: [:index, :create]

        check_permission :branch, :guest_queue, {
          [:index, :reprint, :print_pre_order, :show] => :show,
          create: :create,
          pass: :pass,
          requeue: :requeue,
          accept: :accept,
          cancel: :cancel,
          notify: :notify
        }
        def index
          @q = @current_branch.guest_queues.ransack(params[:q])
          @guest_queues = @q.result(distinct: true).paginate(page: params[:page], per_page: (params[:per_page] || 20))
          fresh_when(@guest_queues)
        end

        # params: {
        #   terminal_id: xxx,
        #   guest_queue: {:guest_num, :queue_setting_id, :phone, :is_local_printed}
        # }
        def create
          if @current_branch.arranging_setting.is_auto_assigned?
            @queue_setting = Ddt::QueueSetting.find_available_queue(guest_queue_param[:guest_num], @current_branch)
          elsif @current_branch.arranging_setting.is_free_choice?
            @queue_setting = Ddt::QueueSetting.find_by_id(guest_queue_param[:queue_setting_id])
          end
          if @queue_setting
            @guest_queue = @queue_setting.new_guest_queue(guest_queue_param.merge(terminal_id: params[:terminal_id]))
            @current_branch.reload
            if @guest_queue.valid?
              render :show
            else
              render json: { errors: @guest_queue.errors.full_messages }, status: :bad_request
            end
          else
            render json: { errors: I18n.t('no queue_setting for this branch') }, status: :bad_request
          end
        end

        def pass
          @guest_queue.pass!
          render :show
        end

        def requeue
          @guest_queue.requeue!
          render :show
        end

        def accept
          @guest_queue.accept!
          render :show
        end

        def cancel
          @guest_queue.cancel!
          render :show
        end

        def notify
          @guest_queue.notify
          render :show
        end

        def reprint
          @guest_queue.reprint
          render :show
        end

        def print_pre_order
          @guest_queue.print_pre_order
          render :show
        end

        def show
        end

        private

          def guest_queue_param
            params.require(:guest_queue).permit(:guest_num, :queue_setting_id, :phone, :is_local_printed)
          end

          def set_guest_queue
            @guest_queue = @current_branch.guest_queues.find(params[:id])
          end

          def queue_bill(guest_queue)
            case params[:bill_type].to_s
            when '58'
              guest_queue.detail_in_bill('58')
            when '80'
              guest_queue.detail_in_bill('80')
            when 'html'
              guest_queue.detail_in_html
            else
              guest_queue.detail_in_html
            end
          end

      end
    end
  end
end
