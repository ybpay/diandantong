module Ddt
  module CommonApi
    module V1
      class PrintersController < V1::BaseController
        check_permission :branch, :order, { reprint: :reprint }, only: [:reprint]
        check_permission :branch, :printer, { [:show] => :show, update: :update}, only: [:show, :update]

        # TODO remove
        skip_before_action :authenticate_account_from_token!, only: :notify_error
        before_action :set_order, only: [:reprint]
        before_action :set_printer, only: [:show, :update]

        def index
          @printers = @current_branch.printers
          fresh_when(@printers)
        end

        def reprint
          @order.reprint(params[:printer_ids], params[:note], current_account)
          render json: {}
        end

        def test_print
          if params[:printer_ids].present?
            printers = @current_branch.printers.find(params[:printer_ids])
          else
            printers = @current_branch.printers.active
          end

          if printers.present?
            printers.each{|printer| printer.print("#{printer.name} 打印测试成功", 1)}
            render json: {count: printers.count}
          else
            render json: {errors: '对不起，当前没有打印机可供测试'}, status: :bad_request
          end

        end

        def show
        end

        def update
          @printer.update(printer_params)
          render :show
        end

        def notify_error
          printers = Ddt::Printer.where(number: params[:printer_code])
          if printers.present?
            printers.each do |printer|
              printer.notify_error(params[:print_state], params[:print_state_reason])
            end
            head 200, content_type: 'text/html'
          else
            # 不存在对应打印机
            head 400, content_type: 'text/html'
          end
        end

        private
        def set_order
          @order = @current_branch.orders.find(params[:order_id])
        end

        def set_printer
          @printer = @current_branch.printers.find(params[:id])
        end

        def printer_params
          params.require(:printer).permit(:name, :number, :type, :api_key, :member_code,
            :phone, :enable, :times, :token, :is_print_all, :print_one_by_one, :use_scene,
            :print_spec, :print_per_product)
        end

      end
    end
  end
end
