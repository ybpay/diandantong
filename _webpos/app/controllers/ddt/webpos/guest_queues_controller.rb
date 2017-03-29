module Ddt
  module Webpos
    class GuestQueuesController < Webpos::BaseController
      include Ddt::Webpos::QueueBill
      before_action :set_queue_setting
      before_action :set_guest_queue, only: [:pass, :requeue, :accept, :cancel, :notify, :reprint, :bill, :show, :print_pre_order, :pre_order_bill]
      check_permission :branch, :guest_queue,{
        create: :create,
        [:index, :show, :bill, :reprint, :print_pre_order, :pre_order_bill] => :show,
        pass: :pass,
        requeue: :requeue,
        accept: :accept,
        cancel: :cancel,
        notify: :notify,
      }
      def create
        @guest_queue = @queue_setting.new_guest_queue(guest_queue_params)
        if @guest_queue.valid?
          render json: {}
        else
          render json: { errors: @guest_queue.errors.full_messages }, status: :bad_request
        end
      end

      def index
        @q = @queue_setting.guest_queues.ransack(params[:q])
        @guest_queues = @q.result(distinct: true).paginate(page: params[:page], per_page: (params[:per_page] || 20))
        fresh_when(@guest_queues)
      end

      def pass
        @guest_queue.pass!
        render :show
      end

      rescue_from Workflow::NoTransitionAllowed do |exception|
        render json: { error: "等位号码#{@guest_queue.guest_no}已经是#{@guest_queue.workflow_state_name}状态" }, status: :bad_request
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

      def bill
        render json: { bill: queue_bill(@guest_queue) }
      end

      def pre_order_bill
        case params[:bill_type]
        when '58'
          @bill = @guest_queue.pre_order_detail_in_bill('58')
        when '80'
          @bill = @guest_queue.pre_order_detail_in_bill('80')
        when 'html'
          @bill = @guest_queue.pre_order_detail_in_html
        else
          @bill = @guest_queue.pre_order_detail_in_html
        end
        render json: { bill: @bill }
      end

      def show
      end

      private
      def guest_queue_params
        params.require(:guest_queue).permit(:guest_num, :phone)
      end

      def set_queue_setting
        @queue_setting = @current_branch.queue_settings.find(params[:queue_setting_id])
      end

      def set_guest_queue
        @guest_queue = @queue_setting.guest_queues.find(params[:id])
        @guest_queue.terminal_id = params[:terminal_id]
      end
    end
  end
end
