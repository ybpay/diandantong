module Ddt
  module Webpos
    class PrintersController < Webpos::BaseController
      before_action :set_order, only: [:reprint]
      check_permission :branch, :order, :reprint

      def index
        @printers = @current_branch.printers.active
        fresh_when(@printers)
      end

      def reprint
        @order.reprint(params[:printer_ids], params[:note], current_account)
        render json: {}
      end

      def get_states
        render json: Ddt::Printer.get_states(@current_branch)
      end

      def test_print
        printer = @current_branch.printers.active.find(params[:id])
        printer.test_print if printer.present?
        render nothing: true, status: 200, content_type: 'application/javascript'
      end

      def test_print_all
        @current_branch.printers.active.find_each do |printer|
          printer.test_print
        end
        render nothing: true, status: 200, content_type: 'application/javascript'
      end

      private
      def set_order
        @order = @current_branch.orders.find(params[:order_id])
      end

    end
  end
end