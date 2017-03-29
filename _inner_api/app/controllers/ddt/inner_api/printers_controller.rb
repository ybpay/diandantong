module Ddt
  module InnerApi
    class PrintersController < InnerApi::BaseController

      def notify_error
        printers = Ddt::Printer.active.where(number: params[:printer_code])
        if printers.present?
          printers.each do |printer|
            printer.notify_error(params[:print_state], params[:print_state_reason])
          end
          render nothing: true, status: 200, content_type: 'text/html'
        else
          # 不存在对应打印机
          render nothing: true, status: 404, content_type: 'text/html'
        end
      end

      def notify_not_working
        printers = Ddt::Printer.active.where(number: params[:printer_code])
        if printers.present?
          printers.each do |printer|
            printer.notify_not_working(params[:last_print_success_at])
          end
          render nothing: true, status: 200, content_type: 'text/html'
        else
          # 不存在对应打印机
          render nothing: true, status: 404, content_type: 'text/html'
        end
      end

      def batch_notify_not_working
        if params[:printers].present?
          # {
          #     printer_code: self.printer_code,
          #     last_print_success_at: self.last_print_success_at
          # }
          printers = params[:printers]
          Ddt::Printer.active.where(number: printers.keys).find_each do |printer|
            printer.notify_not_working(printers[printer.number.to_sym])
          end
        end
        render nothing: true, status: 200, content_type: 'text/html'
      end

    end
  end
end