module Ddt
  module Backend
    module Branch
      class PrintRecordsController < ::Ddt::Backend::BaseController
        check_permission :branch, :print_record, {index: :show}
        before_action :set_printer
        layout "ddt/layouts/backend/branch"
        def index
          @print_records = @printer.print_records.paginate(page: params[:page]).order(created_at: :desc)
        end

        private
        def set_printer
          @printer = @current_branch.printers.find(params[:printer_id])
        end
      end
    end
  end
end
